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
  default = "northeurope"
}

variable "domain_name" {
  type    = string
  default = "aliberkyildiz.com"
}

variable "container_image" {
  description = "Immutable public Docker Hub image used for the initial Container App revision."
  type        = string
  default     = "docker.io/aliberkyldz/portfolio:1.0.0"
}

variable "min_replicas" {
  description = "Zero enables scale-to-zero and minimizes idle cost."
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "A conservative cap prevents unexpected personal-project spend."
  type        = number
  default     = 2
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
