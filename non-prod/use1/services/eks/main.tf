terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "terraform_remote_state" "vpc" {
    backend = "s3"
    config  = {
        bucket = "hibu-nonprod-terraform-state"
        key    = "non-prod/use1/network/vpc/terraform.tfstate"
        region = "us-east-1"
    }
}

module "eks" {
    source                              = "git@github.com:stefengeoffrey/devops-terraform-modules.git//eks?ref=86621c9c5a534ccf163582f7b74c9772d181b73f"
    cluster_name                        =  var.cluster_name
    environment                         =  var.environment
    eks_node_group_instance_types       =  var.eks_node_group_instance_types
    private_subnets                     =  data.terraform_remote_state.vpc.outputs.aws_subnets_private
    public_subnets                      =  data.terraform_remote_state.vpc.outputs.aws_subnets_public
    region                              =  var.region
}



