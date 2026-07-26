variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "domain_name" {
  type    = string
  default = "aliberkyildiz.com"
}

variable "kubernetes_version" {
  type    = string
  default = null
}

variable "system_node_vm_size" {
  description = "B-series is cost-effective but verify regional AKS support before apply."
  type        = string
  default     = "Standard_B2s"
}

variable "enable_spot_pool" {
  description = "Spot reduces compute cost but can be evicted; production remains functional on the system pool."
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Azure Monitor is useful for the case study but is the largest variable cost; retention is kept low."
  type        = bool
  default     = true
}

variable "tags" {
  type = map(string)
  default = {
    project    = "portfolio"
    managed-by = "terraform"
    owner      = "ali-berk-yildiz"
  }
}
