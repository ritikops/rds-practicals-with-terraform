
# import boto3
# import os
# import json

# s3 = boto3.client('s3')
# rds = boto3.client('rds')
# sns = boto3.client('sns')

# def handler(event, context):
#     detail = event['detail']
#     msg = json.dumps(detail)

#     print("Received RDS event:", msg)

#     if 'EventID' in detail and 'RDS-EVENT-0013' in detail['EventID']:
#         snapshot_id = detail['SourceIdentifier']
#         bucket = os.environ['BUCKET_NAME']
#         kms_key = os.environ['KMS_KEY_ID']
#         role_arn = os.environ['EXPORT_ROLE_ARN']

#         print(f"Exporting snapshot {snapshot_id} to bucket {bucket}")
#         rds.start_export_task(
#             ExportTaskIdentifier=f"export-{snapshot_id}",
#             SourceArn=f"arn:aws:rds:{event['region']}:{event['account']}:snapshot:{snapshot_id}",
#             S3BucketName=bucket,
#             IamRoleArn=role_arn,
#             KmsKeyId=kms_key
#         )

#     sns.publish(
#         TopicArn=os.environ['SNS_TOPIC_ARN'],
#         Message=msg,
#         Subject='RDS Event Notification'
#     )

import boto3
import os
import requests

def send_to_slack(message):
    webhook_url = os.environ['https://iqinfinite.webhook.office.com/webhookb2/f20e6eb8-982c-4024-9e60-a2e46a27cb80@b6859703-4fa9-46af-b7a6-c453ed19dd3d/IncomingWebhook/dab484c21e4e45218c0d69505463c788/97973af2-3701-4b6c-b775-bb789e97f515/V2R36EOYuNLq5EgViirpHVgYlpo59RORupqxMjkD6yWcg1']
    payload = {"text": message}
    requests.post(webhook_url, json=payload)

def lambda_handler(event, context):
    client = boto3.client('rds')
    snapshot_arn = event['detail'].get('SourceArn')
    export_id = f"export-{snapshot_arn.split(':')[-1]}-{context.aws_request_id[:6]}"
    response = client.start_export_task(
        ExportTaskIdentifier=export_id,
        SourceArn=snapshot_arn,
        S3BucketName=os.environ['S3_BUCKET_NAME'],
        IamRoleArn=os.environ['EXPORT_ROLE_ARN'],
        KmsKeyId=os.environ['KMS_KEY_ID']
    )
    send_to_slack(f"Export started: {response}")