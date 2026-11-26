variable "project_name" {
  description = "Project identifier"
  type        = string
  default     = "local-devops"
}

variable "project_root" {
  description = "Absolute root directory on the Ubuntu host"
  type        = string
  default     = "/opt/local-devops"
}

variable "environment_name" {
  description = "Currently selected environment"
  type        = string
  default     = "development"

  validation {
    condition     = contains(["development", "testing", "production"], var.environment_name)
    error_message = "environment_name must be development, testing, or production."
  }
}

variable "environments" {
  description = "Logical local environments"
  type = map(object({
    port        = number
    app_dir     = string
    description = string
  }))
  default = {
    development = {
      port        = 8081
      app_dir     = "/var/www/local-devops/development"
      description = "Development environment"
    }
    testing = {
      port        = 8082
      app_dir     = "/var/www/local-devops/testing"
      description = "Testing environment"
    }
    production = {
      port        = 8083
      app_dir     = "/var/www/local-devops/production"
      description = "Production environment"
    }
  }
}
