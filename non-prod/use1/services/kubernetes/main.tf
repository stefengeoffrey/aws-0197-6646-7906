terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }

  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
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



resource "null_resource" "install_fluxcd" {
  triggers = {
    always = timestamp()
  }


  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<EOT
      set -e

      echo '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' | flux bootstrap github --owner=stefengeoffrey --repository=flux-env --branch=main --path=clusters/appmesh --personal

    EOT
  }
}


resource "null_resource" "kubectl" {
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/fluxcd/flagger/main/artifacts/flagger/crd.yaml"
    interpreter = [
      "/bin/bash",
      "-c"]

  }

}


resource "helm_release" "flagger" {
  name       = "nginx-ingress-controller"

  repository = "https://flagger.app"
  chart      = "flagger"

  set {
    name  = "meshProvider"
    value = "appmesh"
  }

  set {
    name  = "metricsServer"
    value = "http://appmesh-prometheus:9090"
  }
}



