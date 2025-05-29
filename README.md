# 🌍 Terraform AWS RDS Global Cluster Automation
[![Terraform](https://img.shields.io/badge/Terraform-v1.3%2B-623CE4?logo=terraform)](https://www.terraform.io/)  
[![AWS](https://img.shields.io/badge/AWS-Deployed-FF9900?logo=amazon-aws)](https://aws.amazon.com/rds/aurora/global-database/)  
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)  
[![LinkedIn](https://img.shields.io/badge/LinkedIn-ritik--jain--anilkumar-blue?logo=linkedin)](https://in.linkedin.com/in/ritik-jain-anilkumar)

> End-to-end automation of **Amazon Aurora Global Clusters** with advanced DevOps practices using **Terraform, AWS Lambda, EventBridge, and CloudWatch**.

Automate the provisioning, scaling, monitoring, and cost optimization of **Amazon Aurora Global Databases** using **Terraform, Lambda, CloudWatch, and EventBridge**. This repository covers real-world, production-grade scenarios for high availability, disaster recovery, and operational excellence.

---

## 🚀 Features

✅ **Terraform Infrastructure as Code (IaC)**  
✅ **Multi-Region Aurora Global Cluster**  
✅ **Cross-Region Read Replicas**  
✅ **Custom Lambda-based Failover Logic**  
✅ **EventBridge Monitoring + CloudWatch + SNS Alerts**  
✅ **Dynamic Replica Scaling (Lambda Scheduler)**  
✅ **Snapshot Automation to S3**  
✅ **Cost Optimization using Trusted Advisor (optional)**  

---

## 📁 Project Structure

---

## 📌 Use Cases (Task-wise Breakdown)

### 🔧 Task 1: RDS Global Cluster Automation
- Deploy Aurora Global Database with:
  - Primary writer in `us-east-1`
  - Secondary read-only replica in `eu-west-1`
- Parameterized DB engine, backup window, instance class, KMS, security groups

### 🔄 Task 2: Cross-Region Read Replicas & Failover
- Auto-create Aurora replicas in secondary region
- Custom **Lambda failover function**
- Route53 DNS failover routing based on region health

### 🔔 Task 3: Event-Driven Backups & Monitoring
- Lambda triggered by RDS **EventBridge** notifications:
  - Snapshot completion
  - Replica lag
  - Failover events
- SNS or Slack alerting
- Snapshot exports to **S3**

### 💰 Task 4: Cost Optimization with Lambda Scheduler
- Scale up/down **read replicas** based on time (via CloudWatch cron)
- Check **CPU/Connection metrics** via `DescribeDBClusters`
- Optional: Use **Trusted Advisor** API to report idle clusters

---

## 🛠️ Technologies Used

- **Terraform v1.3+**
- **AWS Provider v5.0+**
- **Amazon Aurora (MySQL/PostgreSQL)**
- **AWS Lambda (Python)**
- **Amazon CloudWatch**
- **AWS IAM**
- **Amazon EventBridge**
- **Amazon SNS**
- **Amazon Route53**
- **Amazon S3**
- **Trusted Advisor API (Optional)**

---

## ⚙️ Setup Instructions

### 1. 🔑 Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform installed (`v1.3+`)
- Python 3.x

### 2. 📦 Initialize Terraform
terraform init
3. 📐 Customize Variables
Edit variables.tf or use terraform.tfvars to override:
db_username           = "admin"
db_password           = "ChangeMe123!"
initial_read_replica_count = 1

4. 🚀 Deploy
terraform apply

5. 📡 Testing
   
Check CloudWatch Logs for Lambda activity
Validate RDS Replicas are scaling on schedule
Failover Route53 & test DNS redirection
Review S3 snapshots

📄 License
This project is licensed under the MIT License.

🔎 Keywords for Discoverability
terraform, aws, rds, aurora, global database, lambda, eventbridge, route53, replica scaling, cost optimization, cloudwatch, sns, iac, devops

👨‍💻 Author
Ritik Shah
DevOps Engineer | Cloud Enthusiast | Automation Advocate
📫 talk.with.ritiks@gmail.com

![Architecture Diagram](https://raw.githubusercontent.com/ritikops/terraform-aws-rds-global-cluster-automation/main/images/architecture-diagram.png)
