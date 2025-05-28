import boto3
import os

rds = boto3.client('rds')

def lambda_handler(event, context):
    cluster_id = os.environ['DB_CLUSTER_ID']
    desired_count = int(event['desired_count'])  # Pass through event
    instances = rds.describe_db_instances()['DBInstances']
    
    current_readers = [
        i for i in instances 
        if i['DBClusterIdentifier'] == cluster_id and i['DBInstanceRole'] == 'READER'
    ]
    
    current_count = len(current_readers)

    if current_count < desired_count:
        for i in range(desired_count - current_count):
            rds.create_db_instance(
                DBInstanceIdentifier=f"{cluster_id}-reader-{i+current_count}",
                DBClusterIdentifier=cluster_id,
                DBInstanceClass=os.environ['INSTANCE_CLASS'],
                Engine="aurora-mysql"
            )
    elif current_count > desired_count:
        for i in current_readers[desired_count:]:
            rds.delete_db_instance(
                DBInstanceIdentifier=i['DBInstanceIdentifier'],
                SkipFinalSnapshot=True
            )
