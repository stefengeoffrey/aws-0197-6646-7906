terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

module "vpc" {
    source                              = "git@github.com:stefengeoffrey/devops-terraform-modules.git//vpc?ref=7726cf4e5bff1017ff21c4de1f688885bf058d28"
    environment                         =  var.environment
    vpc_cidr                            =  var.vpc_cidr
    vpc_name                            =  var.vpc_name
    cluster_name                        =  var.cluster_name
    public_subnets_cidr                 =  var.public_subnets_cidr
    availability_zones_public           =  var.availability_zones_public
    private_subnets_cidr                =  var.private_subnets_cidr
    availability_zones_private          =  var.availability_zones_private
    cidr_block-nat_gw                   =  var.cidr_block-nat_gw
    cidr_block-internet_gw              =  var.cidr_block-internet_gw
}