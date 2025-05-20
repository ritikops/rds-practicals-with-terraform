# Automate Amazon RDS Global Cluster Creation via Terraform


This project provides a **Terraform-based automation** for deploying an Amazon Aurora Global Database across two AWS regions. It demonstrates best practices for multi-region, highly available database infrastructure.

---

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) v1.0 or later
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed and configured
- AWS IAM user with permissions to manage VPC, RDS, KMS, and related resources

---

## Project Structure

```
primary/      # Terraform code for the primary region (writer/global cluster creator)
secondary/    # Terraform code for the secondary region (reader/join global cluster)
modules/      # (Optional) Shared modules for DRY code
terraform.tfvars  # (Optional) Variable values per environment
```

---

## Setup Steps

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/Automate-Amazon-RDS-Global-Cluster-Creation-via-Terraform-1.git
cd Automate-Amazon-RDS-Global-Cluster-Creation-via-Terraform-1
```

### 2. Configure AWS Credentials

Make sure your AWS credentials are set for both regions (either via `aws configure` or environment variables):

```bash
aws configure
```

### 3. Initialize Terraform in Each Region Directory

```bash
cd primary
terraform init
cd ../secondary
terraform init
```

### 4. Review and Edit Variables

- Edit `terraform.tfvars` or `variables.tf` in both `primary/` and `secondary/` as needed (DB name, instance size, etc.).
- Ensure engine versions and identifiers are valid and consistent.

### 5. Deploy Primary Region (Global Cluster Creator)

```bash
cd primary
terraform apply -auto-approve
```

### 6. Deploy Secondary Region (Join as Reader)

- Make sure the global cluster ID from the primary output is referenced in the secondary region variables.
- Then run:

```bash
cd ../secondary
terraform apply -auto-approve
```

### 7. (Optional) Destroy Resources

To clean up:

```bash
cd primary
terraform destroy -auto-approve
cd ../secondary
terraform destroy -auto-approve
```

---

## Notes

- **Do not commit sensitive files** (`*.tfvars` with passwords) to version control.
- **Use unique resource names** if deploying multiple environments.
- **Monitor AWS Console** for resource creation and status.

---

## Security

- Never commit sensitive files (like `*.tfvars` with passwords) to version control.
- Use KMS for encryption at rest.
- Restrict security group ingress to trusted sources.

---

## License

MIT License

---