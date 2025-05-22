import boto3
import os
import json
import logging
import requests
from datetime import datetime

# Initialize AWS clients
rds = boto3.client('rds')
sns = boto3.client('sns')
s3 = boto3.client('s3')
cloudwatch = boto3.client('cloudwatch')

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """Main Lambda function handler for RDS events"""
    try:
        logger.info(f"Received event: {json.dumps(event)}")
        
        # Parse the event detail
        detail = event.get('detail', {})
        event_id = detail.get('EventID', '')
        source_id = detail.get('SourceIdentifier', '')
        source_arn = detail.get('SourceArn', '')
        event_message = detail.get('Message', '')
        
        # Log basic event info
        log_event_details(source_id, event_id, event_message)
        
        # Process different event types
        if is_snapshot_event(event_id, event_message):
            handle_snapshot_event(source_id, source_arn, event_message)
        elif is_replica_lag_event(event_id, event_message):
            handle_replica_lag_event(source_id, event_message)
        elif is_failover_event(event_id, event_message):
            handle_failover_event(source_id, event_message)
        else:
            logger.warning(f"Unhandled event type: {event_id}")
            
        return {'status': 'success'}
        
    except Exception as e:
        logger.error(f"Error processing event: {str(e)}")
        send_notification(
            subject="ERROR: RDS Monitoring Failure",
            message=f"Error processing RDS event: {str(e)}\nEvent: {json.dumps(event)}"
        )
        raise

def log_event_details(source_id, event_id, message):
    """Log event details to CloudWatch"""
    logger.info(f"Event ID: {event_id}")
    logger.info(f"Source ID: {source_id}")
    logger.info(f"Message: {message}")

def is_snapshot_event(event_id, message):
    """Check if event is a snapshot-related event"""
    return (event_id.startswith('RDS-EVENT-00') or 
            "snapshot" in message.lower() or 
            "backup" in message.lower())

def is_replica_lag_event(event_id, message):
    """Check if event is a replica lag event"""
    return (event_id.startswith('RDS-EVENT-01') or 
            "lag" in message.lower() or 
            "replica" in message.lower())

def is_failover_event(event_id, message):
    """Check if event is a failover event"""
    return (event_id.startswith('RDS-EVENT-02') or 
            "failover" in message.lower() or 
            "role change" in message.lower())

def handle_snapshot_event(db_identifier, db_arn, message):
    """Handle snapshot completion events"""
    logger.info(f"Processing snapshot event for {db_identifier}")
    
    # Send notification
    send_notification(
        subject=f"RDS Snapshot Event - {db_identifier}",
        message=f"Snapshot event for {db_identifier}:\n{message}"
    )
    
    # Export snapshot to S3 if this is a completion event
    if any(word in message.lower() for word in ["completed", "finished", "created"]):
        export_snapshot_to_s3(db_identifier, db_arn)

def handle_replica_lag_event(db_identifier, message):
    """Handle replica lag threshold events"""
    logger.info(f"Processing replica lag event for {db_identifier}")
    
    # Extract lag value from message
    lag_threshold = extract_lag_threshold(message)
    
    if lag_threshold:
        # Determine severity based on thresholds
        if lag_threshold > 300:  # 5 minutes
            severity = "CRITICAL"
        elif lag_threshold > 100:  # 1.5 minutes
            severity = "WARNING"
        else:
            severity = "INFO"
        
        if severity in ["WARNING", "CRITICAL"]:
            send_notification(
                subject=f"{severity}: RDS Replica Lag High - {db_identifier}",
                message=f"Replica lag for {db_identifier} is {lag_threshold} seconds:\n{message}"
            )
        
        # Log metric to CloudWatch
        put_cloudwatch_metric(
            namespace="RDS/GlobalCluster",
            metric_name="ReplicaLag",
            dimensions=[{"Name": "DBIdentifier", "Value": db_identifier}],
            value=lag_threshold,
            unit="Seconds"
        )

def handle_failover_event(db_identifier, message):
    """Handle failover events"""
    logger.info(f"Processing failover event for {db_identifier}")
    
    send_notification(
        subject=f"CRITICAL: RDS Failover Event - {db_identifier}",
        message=f"Failover occurred for {db_identifier}:\n{message}"
    )
    
    put_cloudwatch_metric(
        namespace="RDS/GlobalCluster",
        metric_name="FailoverEvent",
        dimensions=[{"Name": "DBIdentifier", "Value": db_identifier}],
        value=1,
        unit="Count"
    )

def export_snapshot_to_s3(db_identifier, db_arn):
    """Export the latest snapshot to S3"""
    try:
        # Get the most recent manual snapshot
        snapshots = rds.describe_db_snapshots(
            DBInstanceIdentifier=db_identifier,
            SnapshotType='manual',
            MaxRecords=20
        )['DBSnapshots']
        
        if not snapshots:
            logger.warning(f"No manual snapshots found for {db_identifier}")
            return
        
        # Sort by most recent
        snapshots.sort(key=lambda x: x['SnapshotCreateTime'], reverse=True)
        latest_snapshot = snapshots[0]
        
        # Check if snapshot is available
        if latest_snapshot['Status'] != 'available':
            logger.warning(f"Latest snapshot not available: {latest_snapshot['DBSnapshotIdentifier']}")
            return
        
        # Generate export task identifier
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        export_task_id = f"export-{db_identifier}-{timestamp}"[:60]  # Max 60 chars
        
        # Get configuration from environment
        s3_bucket = os.environ.get('S3_BACKUP_BUCKET')
        iam_role = os.environ.get('EXPORT_IAM_ROLE')
        kms_key = os.environ.get('KMS_KEY_ID')
        
        if not all([s3_bucket, iam_role, kms_key]):
            logger.error("Missing required environment variables for export")
            return
        
        # Start export task
        response = rds.start_export_task(
            ExportTaskIdentifier=export_task_id,
            SourceArn=latest_snapshot['DBSnapshotArn'],
            S3BucketName=s3_bucket,
            IamRoleArn=iam_role,
            KmsKeyId=kms_key,
            S3Prefix=f"rds-exports/{db_identifier}/"
        )
        
        logger.info(f"Started export task {export_task_id} for snapshot {latest_snapshot['DBSnapshotIdentifier']}")
        
        # Send success notification
        send_notification(
            subject=f"SUCCESS: RDS Snapshot Export Started - {db_identifier}",
            message=f"Export task {export_task_id} started for snapshot {latest_snapshot['DBSnapshotIdentifier']}"
        )
        
    except Exception as e:
        logger.error(f"Error exporting snapshot: {str(e)}")
        send_notification(
            subject=f"ERROR: RDS Snapshot Export Failed - {db_identifier}",
            message=f"Failed to export snapshot for {db_identifier}:\n{str(e)}"
        )
        raise

def send_notification(subject, message):
    """Send notification via SNS or Slack"""
    try:
        # Slack notification
        if 'SLACK_WEBHOOK_URL' in os.environ:
            send_slack_notification(subject, message)
        
        # SNS notification
        if 'SNS_TOPIC_ARN' in os.environ:
            sns.publish(
                TopicArn=os.environ['SNS_TOPIC_ARN'],
                Subject=subject[:100],  # SNS subject limit
                Message=message
            )
            
        # If no notification channels configured, log to CloudWatch
        if 'SLACK_WEBHOOK_URL' not in os.environ and 'SNS_TOPIC_ARN' not in os.environ:
            logger.info(f"Notification would be sent: {subject}\n{message}")
            
    except Exception as e:
        logger.error(f"Error sending notification: {str(e)}")
        raise

def send_slack_notification(subject, message):
    """Send notification to Slack via webhook"""
    try:
        webhook_url = os.environ['SLACK_WEBHOOK_URL']
        slack_message = {
            "text": f"*{subject}*\n{message}",
            "mrkdwn": True
        }
        
        response = requests.post(
            webhook_url,
            json=slack_message,
            headers={'Content-Type': 'application/json'}
        )
        
        if response.status_code != 200:
            logger.error(f"Slack API error: {response.status_code} - {response.text}")
            
    except Exception as e:
        logger.error(f"Error sending Slack notification: {str(e)}")
        raise

def put_cloudwatch_metric(namespace, metric_name, dimensions, value, unit):
    """Put custom metric to CloudWatch"""
    try:
        cloudwatch.put_metric_data(
            Namespace=namespace,
            MetricData=[{
                'MetricName': metric_name,
                'Dimensions': dimensions,
                'Value': value,
                'Unit': unit,
                'Timestamp': datetime.now()
            }]
        )
        logger.info(f"Successfully logged metric {metric_name} with value {value}")
    except Exception as e:
        logger.error(f"Error putting CloudWatch metric: {str(e)}")
        raise

def extract_lag_threshold(message):
    """Extract replica lag value from event message"""
    try:
        # Look for patterns like "lag is 120 seconds"
        import re
        match = re.search(r'lag\s*(?:is|of)\s*(\d+\.?\d*)\s*seconds?', message, re.IGNORECASE)
        if match:
            return float(match.group(1))
        
        # Alternative pattern: "120 seconds of lag"
        match = re.search(r'(\d+\.?\d*)\s*seconds?\s*(?:of|behind)\s*lag', message, re.IGNORECASE)
        if match:
            return float(match.group(1))
            
        return None
    except Exception as e:
        logger.warning(f"Could not extract lag threshold: {str(e)}")
        return None