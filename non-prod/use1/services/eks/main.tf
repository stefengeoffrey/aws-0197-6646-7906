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
    source                              = "git@github.com:stefengeoffrey/devops-terraform-modules.git//eks?ref=87621562d5246c97a956154acb8a2c57cb2b6dba"
    cluster_name                        =  var.cluster_name
    environment                         =  var.environment
    eks_node_group_instance_types       =  var.eks_node_group_instance_types
    private_subnets                     =  data.terraform_remote_state.vpc.outputs.aws_subnets_private
    public_subnets                      =  data.terraform_remote_state.vpc.outputs.aws_subnets_public
    region                              =  var.region
}



#flux bootstrap bitbucket-server \
      #--owner=my-bitbucket-username \
      #--repository=my-repository \
      #--branch=main \
      #--path=clusters/my-cluster \
      #--hostname=my-bitbucket-server.com \
      #--personal

resource "null_resource" "install_fluxcd" {
  triggers = {
    always = timestamp()
  }

  depends_on = [module.eks]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<EOT
      set -e

      echo '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' | flux bootstrap github --owner=stefengeoffrey --repository=flux-env --branch=main --path=clusters/main-non-prod --personal

    EOT
  }
}

/*
resource "null_resource" "kubectl" {
  provisioner "local-exec" {
    command = "kubectl get nodes"
    interpreter = [
      "/bin/bash",
      "-c"]
    #environment = {
    #      KUBECONFIG = base64encode(var.kubeconfig)
    #  }
  }
}
*/