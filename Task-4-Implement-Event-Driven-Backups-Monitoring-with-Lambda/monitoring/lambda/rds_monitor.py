# import boto3
# import os
# import json

# rds = boto3.client('rds')
# s3 = boto3.client('s3')
# sns = boto3.client('sns')

# def lambda_handler(event, context):
#     try:
#         # Process RDS event
#         detail = event.get('detail', {})
#         event_id = detail.get('EventID', '')
#         source_arn = detail.get('SourceArn', '')
        
#         # Handle backup completion events
#         if 'RDS-EVENT-0081' in event_id:  # Backup completed
#             handle_backup(source_arn)
            
#         # Handle failover events
#         elif 'RDS-EVENT-0235' in event_id:  # Failover started
#             handle_failover(source_arn)
            
#         return {
#             'statusCode': 200,
#             'body': json.dumps('Event processed successfully')
#         }
        
#     except Exception as e:
#         send_alert(f"Error processing RDS event: {str(e)}")
#         raise

# def handle_backup(cluster_arn):
#     cluster_id = cluster_arn.split(':')[-1]
#     snapshot_id = f"{cluster_id}-snapshot-{int(time.time())}"
    
#     # Create manual snapshot
#     rds.create_db_cluster_snapshot(
#         DBClusterSnapshotIdentifier=snapshot_id,
#         DBClusterIdentifier=cluster_id
#     )
    
#     # Export to S3
#     export_task_id = f"{snapshot_id}-export"
#     rds.start_export_task(
#         ExportTaskIdentifier=export_task_id,
#         SourceArn=f"{cluster_arn.replace(':cluster:', ':cluster-snapshot:')}:{snapshot_id}",
#         S3BucketName=os.environ['BACKUP_BUCKET'],
#         IamRoleArn=context.invoked_function_arn,
#         KmsKeyId='alias/aws/rds'
#     )
    
#     send_alert(f"Backup exported to S3: {export_task_id}")

# def handle_failover(cluster_arn):
#     cluster_id = cluster_arn.split(':')[-1]
#     send_alert(f"Failover detected for cluster {cluster_id}")

# def send_alert(message):
#     if 'SNS_TOPIC_ARN' in os.environ:
#         sns.publish(
#             TopicArn=os.environ['SNS_TOPIC_ARN'],
#             Message=message,
#             Subject="RDS Global Cluster Alert"
#         )
import boto3
import os
import json
import time

rds = boto3.client('rds')
s3 = boto3.client('s3')
sns = boto3.client('sns')

def lambda_handler(event, context):
    try:
        # Handle CloudWatch Alarm events
        if event.get('source') == 'aws.cloudwatch':
            if event.get('detail-type') == 'CloudWatch Alarm State Change':
                handle_alarm(event)
            return
        
        # Handle RDS events
        detail = event.get('detail', {})
        event_id = detail.get('EventID', '')
        source_arn = detail.get('SourceArn', '')
        
        # Backup completion event
        if 'RDS-EVENT-0081' in event_id:
            handle_backup(source_arn)
            
        # Failover event
        elif 'RDS-EVENT-0235' in event_id:
            handle_failover(source_arn)
            
        # Maintenance/notification events
        elif any(cat in detail.get('EventCategories', []) for cat in ['notification', 'maintenance']):
            handle_notification(detail)
            
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

def handle_alarm(event):
    alarm_name = event.get('detail', {}).get('alarmName', '')
    if alarm_name == 'rds-global-replica-lag':
        lag = event.get('detail', {}).get('state', {}).get('value', 'N/A')
        send_alert(f"Replica lag threshold exceeded: {lag} seconds")

def handle_notification(detail):
    message = detail.get('Message', 'No message content')
    send_alert(f"RDS Notification: {message}")

def send_alert(message):
    # Send to SNS if configured
    if os.environ.get('SNS_TOPIC_ARN'):
        sns.publish(
            TopicArn=os.environ['SNS_TOPIC_ARN'],
            Message=message,
            Subject="RDS Global Cluster Alert"
        )
    
    # Send to Slack if configured
    if os.environ.get('SLACK_WEBHOOK_URL'):
        # Implement Slack webhook integration here
        pass