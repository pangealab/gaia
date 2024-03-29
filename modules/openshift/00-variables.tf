variable "region" {
  description = "The region to deploy the cluster in, e.g: us-east-2."
}

variable "amisize" {
  description = "The size of the cluster nodes, e.g: t2.large. Note that OpenShift will not run on anything smaller than t2.large"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC, e.g: 11.0.0.0/16"
}

variable "subnet_cidr" {
  description = "The CIDR block for the public subnet, e.g: 11.0.1.0/24"
}

variable "key_name" {
  description = "The name of the key to user for ssh access, e.g: consul-cluster"
}

variable "public_key_path" {
  description = "The local public key path, e.g. ~/.ssh/id_rsa.pub"
}

variable "public_hostname" {
  description = "The FDQN of the Master Node (e.g. openshift.sytes.net)"
}

variable "cluster_name" {
  description = "Name of the cluster, e.g: 'openshift-cluster'. Useful when running multiple clusters in the same AWS account."
}

variable "cluster_id" {
  description = "ID of the cluster, e.g: 'openshift-cluster-us-east-2'. Useful when running multiple clusters in the same AWS account."
}

data "aws_availability_zones" "azs" {}
