# Setup our providers so that we have deterministic dependecy resolution. 
provider "aws" {
  region  = "${var.region}"
  version = "~> 2.19"
}

provider "local" {
  version = "~> 1.3"
}

provider "template" {
  version = "~> 2.1"
}

# Save Terraform State to S3 Bucket
terraform {
  backend "s3" {
    bucket = "gaia-terraform-backend"
    key    = "terraform.tfstate"
    region = "us-east-2"
  }
}

//  Create the OpenShift cluster using our module.
module "openshift" {
  source          = "./modules/openshift"
  region          = "${var.region}"
  # amisize       = "t2.large"    //  Smallest that meets the min specs for OS
  amisize         = "r5a.xlarge"
  vpc_cidr        = "11.0.0.0/16"
  subnet_cidr     = "11.0.1.0/24"
  key_name        = "openshift"
  public_hostname = "${var.public_hostname}"
  public_key_path = "${var.public_key_path}"
  cluster_name    = "openshift-cluster"
  cluster_id      = "openshift-cluster-${var.region}"
}

//  Output some useful variables for quick SSH access etc.
output "master-url" {
  value = "https://${var.public_hostname}:8443"
}
output "master-public_ip" {
  value = "${module.openshift.master-public_ip}"
}
output "bastion-public_ip" {
  value = "${module.openshift.bastion-public_ip}"
}
