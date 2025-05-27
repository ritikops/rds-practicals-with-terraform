import json
import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

sns = boto3.client('sns')
s3 = boto3.client('s3')
rds = boto3.client('rds')

SNS_TOPIC_ARN = os.environ['SNS_TOPIC']
S3_BUCKET = os.environ['S3_BUCKET']

def lambda_handler(event, context):
    logger.info("Received event: %s", json.dumps(event))

    detail_type = event.get('detail-type')
    detail = event.get('detail', {})

    try:
        if detail_type == 'RDS DB Snapshot Event' and 'snapshotId' in detail:
            snapshot_id = detail['snapshotId']
            logger.info(f"Snapshot completed: {snapshot_id}")

            rds.start_export_task(
                ExportTaskIdentifier=f"export-{snapshot_id}",
                SourceArn=detail['SourceArn'],
                S3BucketName=S3_BUCKET,
                IamRoleArn=os.environ['AWS_LAMBDA_FUNCTION_ROLE'],
                KmsKeyId='alias/aws/s3'
            )

            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=f"Snapshot {snapshot_id} exported to {S3_BUCKET}",
                Subject="RDS Snapshot Exported"
            )

        elif "replicaLag" in detail:
            lag = detail["replicaLag"]
            logger.warning(f"Replica lag detected: {lag}")
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=f"Replica lag threshold breached: {lag}",
                Subject="RDS Replica Lag Warning"
            )

        elif detail_type == 'RDS Event Notification':
            logger.warning("Failover or other event detected.")
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=f"Failover or RDS event detected: {detail}",
                Subject="RDS Failover Alert"
            )

    except Exception as e:
        logger.error("Error processing event: %s", str(e))
        raise e
