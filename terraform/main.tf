locals {
  selected = var.environments[var.environment_name]

  nginx_available = "/etc/nginx/sites-available"
  nginx_enabled   = "/etc/nginx/sites-enabled"
  inventory_path  = "${path.module}/../ansible/inventory/hosts.ini"
  runtime_root    = "${path.module}/../runtime"
  metadata_path   = "${local.runtime_root}/environments/${var.environment_name}.json"
}

# Create each logical application directory.
resource "local_file" "application_directory_marker" {
  for_each = var.environments

  content              = "# Managed by Terraform\n# ${each.value.description}\n"
  filename             = "${local.runtime_root}/managed-markers/${each.key}.txt"
  file_permission      = "0644"
  directory_permission = "0755"
}

# Generate a small environment configuration file for documentation and automation.
resource "local_file" "environment_config" {
  for_each = var.environments

  content = templatefile("${path.module}/templates/environment.conf.tmpl", {
    name        = each.key
    description = each.value.description
    port        = each.value.port
    app_dir     = each.value.app_dir
  })
  filename             = "${local.runtime_root}/environments/${each.key}.conf"
  file_permission      = "0644"
  directory_permission = "0755"
}

# Generate a machine-readable metadata file for the selected environment.
resource "local_file" "selected_metadata" {
  content = jsonencode({
    project_name = var.project_name
    environment  = var.environment_name
    description  = local.selected.description
    port         = local.selected.port
    app_dir      = local.selected.app_dir
  })
  filename             = local.metadata_path
  file_permission      = "0644"
  directory_permission = "0755"
}

# The inventory is generated locally and consumed by the Ansible playbook.
resource "local_file" "ansible_inventory" {
  content              = <<-EOT
    [local]
    localhost ansible_connection=local ansible_python_interpreter=/usr/bin/python3

    [web]
    localhost ansible_connection=local

    [monitoring]
    localhost ansible_connection=local
  EOT
  filename             = local.inventory_path
  file_permission      = "0644"
  directory_permission = "0755"
}
