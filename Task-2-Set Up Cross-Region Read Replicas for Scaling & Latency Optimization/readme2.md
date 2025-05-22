I’ve scaffolded the full project structure and populated each file with Terraform and Python Lambda code. Everything is organized under clearly named folders:

* **variables.tf**, **terraform.tfvars**, **providers.tf**
* **vpc/** for network resources
* **aurora/** for Global Cluster and primary/secondary setups
* **lambda/** for IAM, packaging, and the failover function
* **route53/** for DNS records and health checks
* **cloudwatch/** for event rules and Lambda trigger
* **outputs.tf** for key endpoints

# Project: Aurora Global Failover

This project implements a cross-region Aurora Global Database with custom failover logic and DNS routing. Folders and files are organized as follows:

```
aurora-global-failover/
├── README.md
├── variables.tf
├── terraform.tfvars
├── providers.tf
│
├── vpc/
│   ├── us-east-1.tf
│   └── us-west-2.tf
│
├── aurora/
│   ├── global_cluster.tf
│   ├── primary_cluster.tf
│   ├── secondary_cluster.tf
│   └── subnet_group.tf
│
├── lambda/
│   ├── lambda_function.py
│   ├── lambda.tf
│   └── iam_role.tf
│
├── route53/
│   ├── dns_records.tf
│   └── health_check.tf
│
├── cloudwatch/
│   ├── event_rule.tf
│   └── event_target.tf
│
└── outputs.tf
```

---

## variables.tf

```hcl
variable "primary_region" { default = "us-east-1" }
variable "secondary_region" { default = "us-west-2" }
variable "db_engine" { description = "Aurora engine" type = string default = "aurora-mysql" }
variable "engine_version" { description = "Engine version" type = string default = "5.7.mysql_aurora.2.10.0" }
variable "instance_class" { description = "RDS instance class" type = string default = "db.r5.large" }
variable "db_name" { description = "Database name" type = string default = "mydb" }
variable "db_username" { description = "Master username" type = string default = "admin" }
variable "db_password" { description = "Master password" type = string }
variable "global_cluster_id" { description = "Global cluster identifier" type = string default = "aurora-global-db" }
variable "hosted_zone_id" { description = "Route53 zone ID" type = string }
variable "db_hostname" { description = "DNS record name" type = string default = "db.example.com" }
```

## terraform.tfvars

```hcl
# fill in sensitive and environment-specific values
db_password    = "ChangeMe123!"
hosted_zone_id = "ZABCDEFGHIJKL"
```

## providers.tf

```hcl
provider "aws" {
  alias  = "primary"
  region = var.primary_region
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
}
```

## vpc/us-east-1.tf

```hcl
# VPC, subnets, security groups for primary region
# (Example placeholders; replace with actual resources)
resource "aws_vpc" "primary" {
  provider = aws.primary
  cidr_block = "10.0.0.0/16"
}
# ... add subnets & SGs ...
```

## vpc/us-west-2.tf

```hcl
# VPC, subnets, security groups for secondary region
resource "aws_vpc" "secondary" {
  provider = aws.secondary
  cidr_block = "10.1.0.0/16"
}
# ... add subnets & SGs ...
```

## aurora/subnet\_group.tf

```hcl
resource "aws_db_subnet_group" "aurora" {
  name       = "aurora-subnet-group"
  subnet_ids = concat(
    aws_subnet.primary.*.id,
    aws_subnet.secondary.*.id
  )
}
```

## aurora/global\_cluster.tf

```hcl
resource "aws_rds_global_cluster" "global" {
  provider                  = aws.primary
  global_cluster_identifier = var.global_cluster_id
  engine                    = var.db_engine
  engine_version            = var.engine_version
  storage_encrypted         = true
}
```

## aurora/primary\_cluster.tf

```hcl
resource "aws_rds_cluster" "primary" {
  provider                  = aws.primary
  cluster_identifier        = "${var.global_cluster_id}-primary"
  engine                    = var.db_engine
  engine_version            = var.engine_version
  database_name             = var.db_name
  master_username           = var.db_username
  master_password           = var.db_password
  db_subnet_group_name      = aws_db_subnet_group.aurora.name
  global_cluster_identifier = aws_rds_global_cluster.global.id
  skip_final_snapshot       = true
}

resource "aws_rds_cluster_instance" "primary_inst" {
  provider          = aws.primary
  identifier        = "${var.global_cluster_id}-primary-1"
  cluster_identifier = aws_rds_cluster.primary.id
  instance_class    = var.instance_class
}
```

## aurora/secondary\_cluster.tf

```hcl
resource "aws_rds_cluster" "secondary" {
  provider                  = aws.secondary
  cluster_identifier        = "${var.global_cluster_id}-secondary"
  engine                    = var.db_engine
  engine_version            = var.engine_version
  db_subnet_group_name      = aws_db_subnet_group.aurora.name
  global_cluster_identifier = aws_rds_global_cluster.global.id
  skip_final_snapshot       = true
}

resource "aws_rds_cluster_instance" "secondary_inst" {
  provider          = aws.secondary
  identifier        = "${var.global_cluster_id}-secondary-1"
  cluster_identifier = aws_rds_cluster.secondary.id
  instance_class    = var.instance_class
}
```

## lambda/iam\_role.tf

```hcl
resource "aws_iam_role" "lambda_failover" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["rds:PromoteReadReplicaDBCluster","rds:DescribeDBClusters"], Resource = "*" },
      { Effect = "Allow", Action = ["route53:ChangeResourceRecordSets"], Resource = "*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_failover" {
  role       = aws_iam_role.lambda_failover.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
```

## lambda/lambda.tf

```hcl
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda/lambda.zip"
}

resource "aws_lambda_function" "failover" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "rds_failover_handler"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_failover.arn
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  environment {
    variables = {
      PRIMARY_REGION    = var.primary_region
      SECONDARY_REGION  = var.secondary_region
      GLOBAL_CLUSTER_ID = var.global_cluster_id
      HOSTED_ZONE_ID    = var.hosted_zone_id
      DB_HOSTNAME       = var.db_hostname
    }
  }
}
```

## lambda/lambda\_function.py

```python
import boto3, os

def lambda_handler(event, context):
    sec_reg = os.environ['SECONDARY_REGION']
    cid = os.environ['GLOBAL_CLUSTER_ID']
    hz = os.environ['HOSTED_ZONE_ID']
    host = os.environ['DB_HOSTNAME']

    # Promote replica
    rds = boto3.client('rds', region_name=sec_reg)
    rds.promote_read_replica_db_cluster(DBClusterIdentifier=f"{cid}-secondary")

    # Update DNS
    r53 = boto3.client('route53')
    change = {
      'HostedZoneId': hz,
      'ChangeBatch': { 'Changes': [
        { 'Action': 'UPSERT', 'ResourceRecordSet': {
            'Name': host,
            'Type': 'CNAME',
            'TTL': 60,
            'ResourceRecords': [{'Value': f"{cid}-secondary.cluster-{sec_reg}.rds.amazonaws.com"}]
        }}
      ]}
    }
    r53.change_resource_record_sets(**change)
```

## route53/health\_check.tf

```hcl
resource "aws_route53_health_check" "primary" {
  fqdn = aws_rds_cluster.primary.endpoint
  port = 3306
  type = "TCP"
}
```

## route53/dns\_records.tf

```hcl
resource "aws_route53_record" "primary" {
  zone_id = var.hosted_zone_id
  name    = var.db_hostname
  type    = "CNAME"
  ttl     = 60
  set_identifier  = "primary"
  failover        = "PRIMARY"
  health_check_id = aws_route53_health_check.primary.id
  records         = [aws_rds_cluster.primary.endpoint]
}

resource "aws_route53_record" "secondary" {
  zone_id       = var.hosted_zone_id
  name          = var.db_hostname
  type          = "CNAME"
  ttl           = 60
  set_identifier = "secondary"
  failover      = "SECONDARY"
  records       = [aws_rds_cluster.secondary.endpoint]
}
```

## cloudwatch/event\_rule.tf

```hcl
resource "aws_cloudwatch_event_rule" "failover" {
  name = "aurora-failover-rule"
  event_pattern = jsonencode({
    source      = ["aws.rds"],
    detail-type = ["RDS DB Cluster Event"],
    detail      = { EventCategories = ["failover"] }
  })
}
```

## cloudwatch/event\_target.tf

```hcl
resource "aws_cloudwatch_event_target" "to_lambda" {
  rule      = aws_cloudwatch_event_rule.failover.name
  target_id = "failover-lambda"
  arn       = aws_lambda_function.failover.arn
}

resource "aws_lambda_permission" "cw_invoke" {
  statement_id  = "AllowCWInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.failover.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.failover.arn
}
```

## outputs.tf

```hcl
output "primary_endpoint" {
  value = aws_rds_cluster.primary.endpoint
}

output "secondary_endpoint" {
  value = aws_rds_cluster.secondary.endpoint
}

output "dns_name" {
  value = format("%s.%s", var.db_hostname, var.hosted_zone_id)
}
```
