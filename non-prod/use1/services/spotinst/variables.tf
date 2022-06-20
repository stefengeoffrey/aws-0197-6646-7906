// region spotinst/ocean-eks

variable "spotinst_token" {
  type        = string
  description = "Spot Personal Access token"
}

variable "spotinst_account" {
  type        = string
  description = "Spot account ID"
}

variable "cluster_identifier" {
  type        = string
  description = "Cluster identifier"
  default     = null
}

variable "ami_id" {
  type        = string
  description = "The image ID for the EKS worker nodes. If none is provided, Terraform will search for the latest version of their EKS optimized worker AMI based on platform"
  default     = null
}

variable "worker_user_data" {
  type        = string
  description = "User data to pass to worker node instances. If none is provided, a default Linux EKS bootstrap script is used"
  default     = null
}

variable "root_volume_size" {
  type        = string
  description = "The size (in GiB) to allocate for the root volume"
  default     = null
}

variable "min_size" {
  type        = number
  description = "The lower limit of worker nodes the Ocean cluster can scale down to"
  default     = null
}

variable "max_size" {
  type        = number
  description = "The upper limit of worker nodes the Ocean cluster can scale up to"
  default     = null
}

variable "desired_capacity" {
  type        = number
  description = "The number of worker nodes to launch and maintain in the Ocean cluster"
  default     = 1
}

variable "key_name" {
  type        = string
  description = "The key pair to attach to the worker nodes launched by Ocean"
  default     = null
}

variable "associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address to worker nodes"
  default     = false
}

variable "whitelist" {
  type        = list(string)
  description = "List of instance types allowed in the Ocean cluster (`whitelist` and `blacklist` are mutually exclusive)"
  default     = null
}

variable "blacklist" {
  type        = list(string)
  description = "List of instance types not allowed in the Ocean cluster (`whitelist` and `blacklist` are mutually exclusive)"
  default     = null
}

variable "create_ocean" {
  type        = bool
  description = "Controls whether Ocean should be created (it affects all Ocean resources)"
  default     = true
}

variable "spot_percentage" {
  type        = number
  description = "Sets the percentage of nodes that should be Spot (vs On-Demand) in the cluster"
  default     = null
}

variable "autoscaler_is_enabled" {
  type        = bool
  description = "Controls whether Ocean Auto Scaler should be enabled"
  default     = true
}

variable "autoscaler_is_auto_config" {
  type        = bool
  description = "Controls whether Ocean Auto Scaler should be auto configured"
  default     = true
}

variable "autoscaler_headroom_percentage" {
  type        = number
  description = "Sets the auto headroom percentage (a number in the range [0, 200]) which controls the percentage of headroom from the cluster. Relevant only when `autoscale_is_auto_config` toggled on"
  default     = null
}

variable "autoscaler_headroom_cpu_per_unit" {
  type        = number
  description = "Configures the number of CPUs to allocate the headroom (CPUs are denoted in millicores, where 1000 millicores = 1 vCPU)"
  default     = null
}

variable "autoscaler_headroom_gpu_per_unit" {
  type        = number
  description = "Configures the number of GPUs to allocate the headroom"
  default     = null
}

variable "autoscaler_headroom_memory_per_unit" {
  type        = number
  description = "Configures the amount of memory (MB) to allocate the headroom"
  default     = null
}

variable "autoscaler_headroom_num_of_units" {
  type        = number
  description = "Sets the number of units to retain as headroom, where each unit has the defined headroom CPU and memory"
  default     = null
}

variable "autoscaler_cooldown" {
  type        = number
  description = "Sets cooldown period between scaling actions"
  default     = null
}

variable "autoscaler_max_scale_down_percentage" {
  type        = number
  description = "Sets the maximum percentage (a number in the range [1, 100]) to scale down"
  default     = null
}

variable "autoscaler_resource_limits_max_vcpu" {
  type        = number
  description = "Sets the maximum cpu in vCPU units that can be allocated to the cluster"
  default     = null
}

variable "autoscaler_resource_limits_max_memory_gib" {
  type        = number
  description = "Sets the maximum memory in GiB units that can be allocated to the cluster"
  default     = null
}

variable "update_policy" {
  type = object({
    should_roll           = bool
    batch_size_percentage = number
    launch_spec_ids       = list(string)
  })
  description = "Configures the cluster update policy"
  default     = null
}

// endregion

// region spotinst/ocean-controller

variable "controller_disable_auto_update" {
  type        = bool
  description = "Controls whether the auto-update feature should be disabled for the Ocean Controller"
  default     = false
}

variable "controller_image" {
  type        = string
  description = "Set the Docker image name for the Ocean Controller that should be deployed"
  default     = "gcr.io/spotinst-artifacts/kubernetes-cluster-controller"
}

variable "controller_node_selector" {
  type        = map(string)
  description = "Specifies the node selector which must match a node's labels for the Ocean Controller resources to be scheduled on that node"
  default     = null
}

variable "image_pull_policy" {
  type        = string
  description = "Image pull policy (one of: Always, Never, IfNotPresent)"
  default     = "Always"
}

// endregion
