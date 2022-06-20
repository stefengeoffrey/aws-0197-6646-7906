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

data "terraform_remote_state" "eks" {
    backend = "s3"
    config  = {
        bucket = "hibu-nonprod-terraform-state"
        key    = "non-prod/use1/services/eks/terraform.tfstate"
        region = "us-east-1"
    }
}

resource "null_resource" "merge_kubeconfig" {
  triggers = {
    always = timestamp()
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<EOT
      set -e
      echo 'Applying Auth ConfigMap with kubectl...'
      aws eks wait cluster-active --name non-prod
      aws eks update-kubeconfig --name non-prod --alias non-prod --region=us-east-1
    EOT
  }
}


module "kubernetes" {
    source                              =  "../../../../../modules/kubernetes"
    cluster_id                          =  data.terraform_remote_state.eks.outputs.cluster_id
    vpc_id                              =  data.terraform_remote_state.vpc.outputs.vpc_id
    cluster_name                        =  data.terraform_remote_state.eks.outputs.cluster_name
}