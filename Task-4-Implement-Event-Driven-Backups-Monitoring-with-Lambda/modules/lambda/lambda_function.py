import json
import boto3
import os
import logging
from botocore.exceptions import ClientError
import urllib3

# Logger setup
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Boto3 clients
sns = boto3.client('sns')
rds = boto3.client('rds')

# Environment variables
SNS_TOPIC_ARN = os.environ['SNS_TOPIC']
S3_BUCKET = os.environ['S3_BUCKET']
KMS_KEY_ID = os.environ.get('KMS_KEY_ID', 'alias/aws/s3')
EXPORT_ROLE_ARN = os.environ['EXPORT_ROLE_ARN']  # IAM role for export, NOT the Lambda role
SLACK_WEBHOOK_URL = os.environ.get('SLACK_WEBHOOK_URL')  # ✅ Use env var, not hardcoded

def lambda_handler(event, context):
    logger.info("Received event:\n%s", json.dumps(event, indent=2))

    detail_type = event.get('detail-type', '')
    detail = event.get('detail', {})

    try:
        if detail_type == 'RDS DB Snapshot Event' and 'snapshotId' in detail:
            snapshot_id = detail['snapshotId']
            source_arn = detail.get('SourceArn')
            if not source_arn:
                raise ValueError("SourceArn not found in snapshot event detail.")

            export_task_id = f"export-{snapshot_id}"
            logger.info(f"Exporting snapshot: {snapshot_id} to S3 bucket: {S3_BUCKET}")

            response = rds.start_export_task(
                ExportTaskIdentifier=export_task_id,
                SourceArn=source_arn,
                S3BucketName=S3_BUCKET,
                IamRoleArn=EXPORT_ROLE_ARN,
                KmsKeyId=KMS_KEY_ID,
                ExportOnly=["database"]
            )

            logger.info("Export task started: %s", json.dumps(response, indent=2))

            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=f"✅ Snapshot `{snapshot_id}` has been exported to `{S3_BUCKET}`.",
                Subject="RDS Snapshot Exported"
            )

        elif "replicaLag" in detail:
            lag = detail["replicaLag"]
            logger.warning(f"Replica lag threshold breached: {lag}")
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=f"⚠️ Replica lag threshold breached: {lag}",
                Subject="RDS Replica Lag Alert"
            )

        elif detail_type == 'RDS Event Notification':
            logger.warning("Failover or other RDS event detected.")
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=f"⚠️ RDS failover or critical event detected:\n{json.dumps(detail, indent=2)}",
                Subject="RDS Failover Alert"
            )

        # Slack Notification (optional)
        if SLACK_WEBHOOK_URL:
            http = urllib3.PoolManager()
            http.request(
                "POST",
                SLACK_WEBHOOK_URL,
                body=json.dumps({"text": f"📢 RDS Event:\n```{json.dumps(detail, indent=2)}```"}),
                headers={"Content-Type": "application/json"}
            )

    except ClientError as e:
        logger.error("AWS ClientError: %s", e.response['Error']['Message'])
        raise e
    except Exception as e:
        logger.error("Unhandled error: %s", str(e))
        raise e
