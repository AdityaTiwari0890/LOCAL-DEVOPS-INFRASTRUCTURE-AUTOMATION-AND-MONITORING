# Terraform

Terraform uses only `hashicorp/local`; it does not require provider credentials.
`main.tf` creates an application marker in each environment directory, environment
configuration files under `/opt/local-devops/environments`, selected metadata,
and `ansible/inventory/hosts.ini`.

`environment_name` chooses one selected environment for metadata and output. The
`environments` variable still creates all three environment resources.

Commands:

```bash
cd terraform
terraform init
terraform fmt -check
terraform validate
terraform plan -var-file=dev.tfvars
terraform apply -var-file=dev.tfvars
terraform output
terraform destroy -var-file=dev.tfvars
```

State remains local. The project does not use `terraform_data`; it is not required
for this implementation. `destroy` removes Terraform-managed resources only.
