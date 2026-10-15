# Basic MariaDB Example

This example provisions a standalone MariaDB cluster using the module from the repository root.

## What This Example Shows

- Single cluster creation
- Required credentials, flavor, storage, and zone
- Security group CIDR allow list
- Minimal optional inputs

## Files

- `main.tf`: provider config + module call
- `variables.tf`: input variables used by the provider block

## How To Run

1. Go to this folder:

```bash
cd examples/basic
```

2. Initialize Terraform:

```bash
terraform init
```

3. Provide your own credentials and project details in a tfvars file (do not commit secrets).

4. Plan:

```bash
terraform plan -var-file=terraform.tfvars
```

5. Apply:

```bash
terraform apply -var-file=terraform.tfvars
```

6. Destroy when done:

```bash
terraform destroy -var-file=terraform.tfvars
```

## Notes

- Use your own Airtel Cloud API credentials.
- Keep credentials and the database password out of version control.
- The installed provider must include `airtelcloud_mariadb`.
- If your environment uses a different region or API endpoint, update provider inputs accordingly.
