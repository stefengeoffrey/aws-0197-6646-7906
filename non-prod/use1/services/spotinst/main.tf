provider "spotinst" {
  token   = var.spotinst_token
  account = var.spotinst_account
}

provider "kubernetes" {
  host                   = module.ocean-eks.cluster_endpoint
  token                  = module.ocean-eks.cluster_token
  cluster_ca_certificate = base64decode(module.ocean-eks.cluster_ca_certificate)
}

module "ocean-eks" {
  source = "../../../../../../modules/ocean"

  # Credentials.
  spotinst_token   = var.spotinst_token
  spotinst_account = var.spotinst_account
}