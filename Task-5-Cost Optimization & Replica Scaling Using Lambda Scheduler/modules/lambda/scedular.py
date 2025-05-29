# import boto3
# import os

# rds = boto3.client('rds')

# def lambda_handler(event, context):
#     cluster_id = os.environ['DB_CLUSTER_ID']
#     desired_count = int(event['desired_count'])  # Pass through event
#     instances = rds.describe_db_instances()['DBInstances']
    
#     current_readers = [
#         i for i in instances 
#         if i['DBClusterIdentifier'] == cluster_id and i['DBInstanceRole'] == 'READER'
#     ]
    
#     current_count = len(current_readers)

#     if current_count < desired_count:
#         for i in range(desired_count - current_count):
#             rds.create_db_instance(
#                 DBInstanceIdentifier=f"{cluster_id}-reader-{i+current_count}",
#                 DBClusterIdentifier=cluster_id,
#                 DBInstanceClass=os.environ['INSTANCE_CLASS'],
#                 Engine="aurora-mysql"
#             )
#     elif current_count > desired_count:
#         for i in current_readers[desired_count:]:
#             rds.delete_db_instance(
#                 DBInstanceIdentifier=i['DBInstanceIdentifier'],
#                 SkipFinalSnapshot=True
#             )
import boto3
import os
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

support = boto3.client('support', region_name='us-east-1')  # Must be us-east-1
sns = boto3.client('sns')
SNS_TOPIC = os.environ['SNS_TOPIC']

# Check ID for "Idle DB Instances"
CHECK_ID = "Qch7DwOuX1"

def lambda_handler(event, context):
    try:
        result = support.describe_trusted_advisor_check_result(
            checkId=CHECK_ID,
            language='en'
        )
        flagged = result['result']['flaggedResources']

        idle_rds = [r for r in flagged if not r['metadata'][4] == 'true']  # Skipping suppressed ones

        if idle_rds:
            logger.info(f"Found {len(idle_rds)} idle RDS instances.")
            instance_list = "\n".join([r['metadata'][0] for r in idle_rds])

            sns.publish(
                TopicArn=SNS_TOPIC,
                Subject="Idle RDS Instances Found",
                Message=f"The following RDS instances are idle:\n{instance_list}"
            )
        else:
            logger.info("No idle RDS instances found.")
    except Exception as e:
        logger.error(f"Failed to get Trusted Advisor result: {str(e)}")
        raise e
