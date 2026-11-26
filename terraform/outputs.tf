output "environment_names" {
  description = "Logical environment names"
  value       = keys(var.environments)
}

output "environment_ports" {
  description = "HTTP ports for all environments"
  value = {
    for name, environment in var.environments : name => environment.port
  }
}

output "environment_paths" {
  description = "Application directories for all environments"
  value = {
    for name, environment in var.environments : name => environment.app_dir
  }
}

output "selected_environment" {
  description = "Name of the selected environment"
  value       = var.environment_name
}

output "selected_port" {
  description = "Port for the selected environment"
  value       = local.selected.port
}

output "selected_app_dir" {
  description = "Application directory for the selected environment"
  value       = local.selected.app_dir
}
