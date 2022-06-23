
variable "github_owner" {
  type        = string
  description = "github owner"
  default     = "stefengeoffrey"
}

variable "github_token" {
  type        = string
  description = "github token"
  default     =  "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"
}

variable "repository_name" {
  type        = string
  default     = "flux-env"
  description = "github repository name"
}

variable "repository_visibility" {
  type        = string
  default     = "public"
  description = "How visible is the github repo"
}

variable "branch" {
  type        = string
  default     = "main"
  description = "branch name"
}

variable "target_path" {
  type        = string
  default     = "clusters/main-non-prod"
  description = "flux sync target path"
}