import boto3
import os
import json

rds = boto3.client('rds')
s3 = boto3.client('s3')
sns = boto3.client('sns')

def lambda_handler(event, context):
    try:
        # Process RDS event
        detail = event.get('detail', {})
        event_id = detail.get('EventID', '')
        source_arn = detail.get('SourceArn', '')
        
        # Handle backup completion events
        if 'RDS-EVENT-0081' in event_id:  # Backup completed
            handle_backup(source_arn)
            
        # Handle failover events
        elif 'RDS-EVENT-0235' in event_id:  # Failover started
            handle_failover(source_arn)
            
        return {
            'statusCode': 200,
            'body': json.dumps('Event processed successfully')
        }
        
    except Exception as e:
        send_alert(f"Error processing RDS event: {str(e)}")
        raise

def handle_backup(cluster_arn):
    cluster_id = cluster_arn.split(':')[-1]
    snapshot_id = f"{cluster_id}-snapshot-{int(time.time())}"
    
    # Create manual snapshot
    rds.create_db_cluster_snapshot(
        DBClusterSnapshotIdentifier=snapshot_id,
        DBClusterIdentifier=cluster_id
    )
    
    # Export to S3
    export_task_id = f"{snapshot_id}-export"
    rds.start_export_task(
        ExportTaskIdentifier=export_task_id,
        SourceArn=f"{cluster_arn.replace(':cluster:', ':cluster-snapshot:')}:{snapshot_id}",
        S3BucketName=os.environ['BACKUP_BUCKET'],
        IamRoleArn=context.invoked_function_arn,
        KmsKeyId='alias/aws/rds'
    )
    
    send_alert(f"Backup exported to S3: {export_task_id}")

def handle_failover(cluster_arn):
    cluster_id = cluster_arn.split(':')[-1]
    send_alert(f"Failover detected for cluster {cluster_id}")

def send_alert(message):
    if 'SNS_TOPIC_ARN' in os.environ:
        sns.publish(
            TopicArn=os.environ['SNS_TOPIC_ARN'],
            Message=message,
            Subject="RDS Global Cluster Alert"
        )