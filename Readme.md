
---

###  **You need to create these resources twice — once per region:**

| Resource                   | Reason Why                                              |
| -------------------------- | ------------------------------------------------------- |
| **VPC**                    | VPCs are regional. You cannot span VPCs across regions. |
| **Subnets**                | Required for RDS subnet group; tied to VPC per region.  |
| **Subnet Group**           | Needed by RDS clusters; must match region and subnets.  |
| **Security Groups**        | Regional; you must define them per region.              |
| **KMS Key**                | KMS keys are regional; each region needs its own.       |
| **RDS Cluster & Instance** | These are regional and must be created separately.      |

---

###  What You Don’t Need Twice

| Resource or Element           | Reason                                                         |
| ----------------------------- | -------------------------------------------------------------- |
| **Global Cluster ID**         | Defined only in the primary; used in secondary.                |
| **Master credentials**        | Can be the same (username/password), but defined per cluster.  |
| **Terraform code (optional)** | Can be reused with modules or parameterized if you prefer DRY. |

---

###  Your Setup Will Look Like This:

#### **Region: `us-east-1` (Primary)**

* VPC 1
* Subnets for DB
* Subnet group 1
* Security group 1
* KMS key 1
* Global Cluster creation
* RDS Cluster writer instance

#### **Region: `eu-west-1` (Secondary)**

* VPC 2
* Subnets for DB
* Subnet group 2
* Security group 2
* KMS key 2
* Join global cluster as reader

---

###  Tips

* Keep naming conventions consistent like:

  * `vpc-global-us-east-1`, `vpc-global-eu-west-1`
  * `sg-global-rds`, `subnet-group-global`
* Reuse Terraform modules or create parameterized code to avoid duplication.
* Use Terraform `terraform_remote_state` or outputs to pass values (like global cluster ID) between regions if needed.

---