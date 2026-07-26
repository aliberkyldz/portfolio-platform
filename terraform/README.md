# Terraform deployment

The remote state account is bootstrapped separately because a Terraform backend
must exist before the main configuration can initialize.

```bash
cd terraform/bootstrap
terraform init
terraform apply

cd ..
cp backend.hcl.example backend.hcl
# Fill values from the bootstrap output.
terraform init -backend-config=backend.hcl
terraform plan -var-file=environments/prod.tfvars
```

The workload identity federation uses the AKS OIDC issuer directly and does not
store Azure client secrets.
