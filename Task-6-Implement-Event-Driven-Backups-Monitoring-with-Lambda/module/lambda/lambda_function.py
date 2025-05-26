import boto3
import os
import json

s3 = boto3.client('s3')
rds = boto3.client('rds')
sns = boto3.client('sns')

def handler(event, context):
    detail = event.get('detail', {})
    msg = json.dumps(detail)

    print("Received RDS event:", msg)

    # Export snapshot if it's completed (example event for snapshot completed: RDS-EVENT-0042)
    if 'SourceIdentifier' in detail and 'SourceType' in detail and detail.get('EventID', '').startswith('RDS-EVENT'):
        snapshot_id = detail['SourceIdentifier']
        bucket = os.environ['BUCKET_NAME']
        region = os.environ.get('AWS_REGION', 'us-east-1')
        account_id = os.environ.get('ACCOUNT_ID')  # must be passed from env
        export_role_arn = os.environ['EXPORT_ROLE_ARN']
        kms_key_id = os.environ['KMS_KEY_ID']

        source_arn = f"arn:aws:rds:{region}:{account_id}:snapshot:{snapshot_id}"

        try:
            print(f"Exporting snapshot {snapshot_id} to bucket {bucket}")
            rds.start_export_task(
                ExportTaskIdentifier=f"export-{snapshot_id}",
                SourceArn=source_arn,
                S3BucketName=bucket,
                IamRoleArn=export_role_arn,
                KmsKeyId=kms_key_id
            )
        except Exception as e:
            print(f"Snapshot export failed: {e}")

    # Publish alert to SNS
    try:
        sns.publish(
            TopicArn=os.environ['SNS_TOPIC_ARN'],
            Message=msg,
            Subject='RDS Event Notification'
        )
    except Exception as e:
        print(f"Failed to publish SNS notification: {e}")
