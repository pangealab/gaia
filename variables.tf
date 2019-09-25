//  The region we will deploy our cluster into.
variable "region" {
  description = "Region to deploy the cluster into"
  default = "us-east-1"
}

//  The public key to use for SSH access.
variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

//  The FDQN of the Master Node
variable "public_hostname" {
  description = "The FDQN of the Master Node (e.g. openshift.hopto.org)"
  default = "openshift.hopto.org"
}