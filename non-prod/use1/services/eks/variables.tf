variable "cluster_name" {
  description = "the name of your stack, e.g. \"demo\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "eks_node_group_instance_types" {
  description  = "Instance type of node group"
}

variable "region" {}
