terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
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
      aws eks wait cluster-active --name '${var.cluster_name}-${var.environment}'
      aws eks update-kubeconfig --name '${var.cluster_name}-${var.environment}' --alias '${var.cluster_name}-${var.environment}-${var.region}' --region=${var.region}
    EOT
  }
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


