# import boto3, os

# def lambda_handler(event, context):
#     sec_reg = os.environ['SECONDARY_REGION']
#     cid = os.environ['GLOBAL_CLUSTER_ID']
#     hz = os.environ['HOSTED_ZONE_ID']
#     host = os.environ['DB_HOSTNAME']

#     rds = boto3.client('rds', region_name=sec_reg)
#     rds.promote_read_replica_db_cluster(DBClusterIdentifier=f"{cid}-secondary")

#     r53 = boto3.client('route53')
#     change = {
#       'HostedZoneId': hz,
#       'ChangeBatch': { 'Changes': [
#         { 'Action': 'UPSERT', 'ResourceRecordSet': {
#             'Name': host,
#             'Type': 'CNAME',
#             'TTL': 60,
#             'ResourceRecords': [{'Value': f"{cid}-secondary.cluster-{sec_reg}.rds.amazonaws.com"}]
#         }}
#       ]}
#     }
#     r53.change_resource_record_sets(**change)

# import boto3
# import os

# def lambda_handler(event, context):
#     sec_reg = os.environ['SECONDARY_REGION']
#     cid = os.environ['GLOBAL_CLUSTER_ID']
#     target_cluster = os.environ['SECONDARY_CLUSTER_ID']

#     rds = boto3.client('rds', region_name=sec_reg)
#     response = rds.failover_global_cluster(
#         GlobalClusterIdentifier=cid,
#         TargetDbClusterIdentifier=target_cluster
#     )
#     return response

import boto3

def handler(event, context):
    rds = boto3.client('rds')
    
    try:
        response = rds.failover_global_cluster(
            GlobalClusterIdentifier=os.environ['GLOBAL_CLUSTER_ID'],
            TargetDbClusterIdentifier=os.environ['SECONDARY_ARN'].split(':')[-1]
        )
        print(f"Failover initiated: {response}")
    except Exception as e:
        print(f"Failover failed: {str(e)}")
        raise