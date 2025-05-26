module "rds_primary" {
  source                = "./modules/rds_cluster"
  region                = "us-east-1"
  role                  = "writer"
  vpc_cidr              = "192.0.0.0/16"
  subnet1_cidr          = "192.0.1.0/24"
  subnet2_cidr          = "192.0.2.0/24"
  availability_zone1    = "us-east-1a"
  availability_zone2    = "us-east-1b"
  sg_cidr_block         = "192.0.0.0/16"
  create_global_cluster = true
  source_region         = ""
}

module "rds_secondary" {
  source                = "./modules/rds_cluster"
  region                = "eu-west-1"
  role                  = "replica"
  vpc_cidr              = "192.1.0.0/16"
  subnet1_cidr          = "192.1.1.0/24"
  subnet2_cidr          = "192.1.2.0/24"
  availability_zone1    = "eu-west-1a"
  availability_zone2    = "eu-west-1b"
  sg_cidr_block         = "192.1.0.0/16"
  create_global_cluster = false
  source_region         = "us-east-1"
}
