# import boto3
# import os
# import json
# import time

# rds = boto3.client('rds')
# s3 = boto3.client('s3')
# sns = boto3.client('sns')

# def lambda_handler(event, context):
#     try:
#         # Handle CloudWatch Alarm events
#         if event.get('source') == 'aws.cloudwatch':
#             if event.get('detail-type') == 'CloudWatch Alarm State Change':
#                 handle_alarm(event)
#             return
        
#         # Handle RDS events
#         detail = event.get('detail', {})
#         event_id = detail.get('EventID', '')
#         source_arn = detail.get('SourceArn', '')
        
#         # Backup completion event
#         if 'RDS-EVENT-0081' in event_id:
#             handle_backup(source_arn)
            
#         # Failover event
#         elif 'RDS-EVENT-0235' in event_id:
#             handle_failover(source_arn)
            
#         # Maintenance/notification events
#         elif any(cat in detail.get('EventCategories', []) for cat in ['notification', 'maintenance']):
#             handle_notification(detail)
            
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

# def handle_alarm(event):
#     alarm_name = event.get('detail', {}).get('alarmName', '')
#     if alarm_name == 'rds-global-replica-lag':
#         lag = event.get('detail', {}).get('state', {}).get('value', 'N/A')
#         send_alert(f"Replica lag threshold exceeded: {lag} seconds")

# def handle_notification(detail):
#     message = detail.get('Message', 'No message content')
#     send_alert(f"RDS Notification: {message}")

# def send_alert(message):
#     # Send to SNS if configured
#     if os.environ.get('SNS_TOPIC_ARN'):
#         sns.publish(
#             TopicArn=os.environ['SNS_TOPIC_ARN'],
#             Message=message,
#             Subject="RDS Global Cluster Alert"
#         )
    
#     # Send to Slack if configured
#     if os.environ.get('SLACK_WEBHOOK_URL'):
#         # Implement Slack webhook integration here
#         pass
# import boto3
# import os
# import json
# from datetime import datetime

# s3 = boto3.client('s3')
# sns = boto3.client('sns')
# rds = boto3.client('rds')

# def lambda_handler(event, context):
#     # Process RDS events
#     if 'source' in event and event['source'] == 'aws.rds':
#         detail = event.get('detail', {})
#         event_id = detail.get('EventID', '')
        
#         # Handle snapshot completion
#         if 'RDS-EVENT-0081' in event_id:  # Backup completed
#             handle_snapshot(detail)
        
#         # Handle failover events
#         elif 'RDS-EVENT-0235' in event_id:  # Failover started
#             handle_failover(detail)
    
#     # Handle CloudWatch alarms (replica lag)
#     elif event.get('source') == 'aws.cloudwatch':
#         handle_alarm(event)
    
#     return {'statusCode': 200}

# def handle_snapshot(detail):
#     cluster_id = detail.get('SourceIdentifier', '')
#     timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
#     snapshot_id = f"{cluster_id}-snapshot-{timestamp}"
    
#     # Create manual snapshot
#     rds.create_db_cluster_snapshot(
#         DBClusterSnapshotIdentifier=snapshot_id,
#         DBClusterIdentifier=cluster_id
#     )
    
#     # Export to S3
#     export_task_id = f"{snapshot_id}-export"
#     rds.start_export_task(
#         ExportTaskIdentifier=export_task_id,
#         SourceArn=f"arn:aws:rds:{os.environ['AWS_REGION']}:{context.invoked_function_arn.split(':')[4]}:cluster-snapshot:{snapshot_id}",
#         S3BucketName=os.environ['BACKUP_BUCKET'],
#         IamRoleArn=context.invoked_function_arn,
#         KmsKeyId=os.environ['KMS_KEY_ARN']
#     )
    
#     send_alert(f"Backup exported to S3: {export_task_id}")

# def handle_failover(detail):
#     cluster_id = detail.get('SourceIdentifier', '')
#     send_alert(f"Failover detected for cluster {cluster_id}")

# def handle_alarm(event):
#     alarm_name = event.get('detail', {}).get('alarmName', '')
#     if 'replica-lag' in alarm_name.lower():
#         send_alert(f"Replica lag threshold exceeded: {event.get('detail', {}).get('state', {}).get('value')}")

# def send_alert(message):
#     sns.publish(
#         TopicArn=os.environ['SNS_TOPIC_ARN'],
#         Message=message,
#         Subject="RDS Global Cluster Alert"
#     )
import boto3
import os
import json
from datetime import datetime

s3 = boto3.client('s3')
rds = boto3.client('rds')
sns = boto3.client('sns')

def lambda_handler(event, context):
    try:
        # Process RDS events
        if event.get('source') == 'aws.rds':
            detail = event.get('detail', {})
            event_id = detail.get('EventID', '')
            
            # Handle automated snapshot completion
            if 'RDS-EVENT-0081' in event_id:  # Backup completed
                handle_snapshot(detail)
                
            # Handle manual snapshot creation
            elif 'RDS-EVENT-0091' in event_id:  # Manual snapshot created
                handle_snapshot(detail)
                
        return {
            'statusCode': 200,
            'body': json.dumps('Snapshot processed successfully')
        }
        
    except Exception as e:
        send_alert(f"Error processing snapshot: {str(e)}")
        raise

def handle_snapshot(detail):
    snapshot_arn = detail.get('SourceArn', '')
    snapshot_id = detail.get('SourceIdentifier', '')
    cluster_id = snapshot_arn.split(':')[-1].replace('snapshot:', 'cluster:')
    
    # Copy snapshot to ensure we own it
    timestamp = datetime.now().strftime('%Y%m%d-%H%M%S')
    copy_id = f"{snapshot_id}-copy-{timestamp}"
    
    rds.copy_db_cluster_snapshot(
        SourceDBClusterSnapshotIdentifier=snapshot_id,
        TargetDBClusterSnapshotIdentifier=copy_id,
        KmsKeyId=os.environ['PRIMARY_KMS_KEY_ARN']
    )
    
    # Export to S3
    export_task_id = f"{copy_id}-export"
    rds.start_export_task(
        ExportTaskIdentifier=export_task_id,
        SourceArn=f"{snapshot_arn.replace('snapshot:', 'cluster-snapshot:')}",
        S3BucketName=os.environ['S3_BACKUP_BUCKET'],
        IamRoleArn=context.invoked_function_arn,
        KmsKeyId=os.environ['PRIMARY_KMS_KEY_ARN']
    )
    
    send_alert(f"Snapshot exported to S3: {export_task_id}")

def send_alert(message):
    sns.publish(
        TopicArn=os.environ['SNS_TOPIC_ARN'],
        Message=message,
        Subject="RDS Snapshot Export Notification"
    )