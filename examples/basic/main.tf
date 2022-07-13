terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.1.0"
    }
  }

  required_version = ">= 1.1.4"
}

provider "aws" {
  region  = "us-west-2"
  profile = "ioasys_andersonpereira"
}

module "eks" {
  source = "../.."

  environment_name                  = "dev"
  cluster_name                      = "basic"
  ami_name                          = "ami-000c09458bbe0fa2a"
  key_pair_name                     = "key_cluster_simple_dev"
  instance_type                     = "t2.small"
  cluster-node-autoscaling-max_size = 2
  cluster-node-autoscaling-min_size = 1
  cluster-node-autoscaling-desired  = 2
  services_accounts                 = {}
}
