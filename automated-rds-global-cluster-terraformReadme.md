# Automate Amazon RDS Global Cluster Creation via Terraform


This project provides a **Terraform-based automation** for deploying an Amazon Aurora Global Database across two AWS regions. It demonstrates best practices for multi-region, highly available database infrastructure.

---

## Architecture Overview

- **Primary Region (`us-east-1`):**
  - VPC, Subnets, Subnet Group
  - Security Group
  - KMS Key
  - Aurora Global Cluster (writer)
  - RDS Cluster Instance (writer)

- **Secondary Region (`eu-west-1`):**
  - VPC, Subnets, Subnet Group
  - Security Group
  - KMS Key
  - RDS Cluster (reader) joining the global cluster
  - RDS Cluster Instance (reader)

---

## Why Duplicate Resources Per Region?

| Resource                   | Reason Why                                              |
| -------------------------- | ------------------------------------------------------- |
| **VPC**                    | VPCs are regional. You cannot span VPCs across regions. |
| **Subnets**                | Required for RDS subnet group; tied to VPC per region.  |
| **Subnet Group**           | Needed by RDS clusters; must match region and subnets.  |
| **Security Groups**        | Regional; you must define them per region.              |
| **KMS Key**                | KMS keys are regional; each region needs its own.       |
| **RDS Cluster & Instance** | These are regional and must be created separately.      |

---

## What You Don’t Need Twice

| Resource or Element           | Reason                                                         |
| ----------------------------- | -------------------------------------------------------------- |
| **Global Cluster ID**         | Defined only in the primary; used in secondary.                |
| **Master credentials**        | Can be the same (username/password), but defined per cluster.  |
| **Terraform code (optional)** | Can be reused with modules or parameterized if you prefer DRY. |

---

## Recommended Naming Conventions

- `vpc-global-us-east-1`, `vpc-global-eu-west-1`
- `sg-global-rds`, `subnet-group-global`
- Use consistent prefixes for easy identification.

---

## Tips for Automation

- **Reuse Terraform modules** or parameterize your code to avoid duplication.
- Use `terraform_remote_state` or outputs to pass values (like the global cluster ID) between regions if needed.
- Keep your `terraform.tfvars` and variable files organized per region.

---

## Getting Started

1. **Clone this repository**
2. **Configure your AWS credentials** for both regions.
3. **Initialize Terraform** in each region's directory:
   ```bash
   terraform init
   ```
4. **Apply the primary region first** (creates the global cluster):
   ```bash
   terraform apply -auto-approve
   ```
5. **Apply the secondary region** (joins the global cluster as a reader):
   ```bash
   terraform apply -auto-approve
   ```

---

## Security

- Never commit sensitive files (like `*.tfvars` with passwords) to version control.
- Use KMS for encryption at rest.
- Restrict security group ingress to trusted sources.

---

## License

MIT License

---