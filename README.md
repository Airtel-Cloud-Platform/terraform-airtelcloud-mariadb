# Airtel Cloud MariaDB Terraform Module

Terraform module for provisioning an Airtel Cloud MariaDB cluster with the
`airtelcloud_mariadb` provider resource.

The provider supports create, read, import, and delete. Configuration changes
force a new cluster. The API does not return the admin password; Terraform
stores the configured value in state.

## Features

- Optional master-slave high availability with replica count
- Optional backup schedule and protection plan
- Client network access via a VPC/subnet, custom CIDRs, or both
- Optional labels and create/delete timeouts
- Outputs for connection details and cluster status

## Requirements

| Name        | Version   |
|-------------|-----------|
| Terraform   | >= 1.5    |
| airtelcloud | >= 2.0.0  |

## Usage

```hcl
variable "mariadb_password" {
  type      = string
  sensitive = true
}

module "mariadb" {
  source = "Airtel-Cloud-Platform/mariadb/airtelcloud"

  cluster_name      = "app-db"
  mariadb_version   = "10.6"
  database_name     = "app"
  mariadb_username  = "dbadmin"
  password          = var.mariadb_password
  compute_size      = "db.maria.uhper.ccs.xlarge"
  storage_size      = 200
  availability_zone = "S1"

  custom_cidr = ["192.168.1.0/24"]
}
```

For VPC/subnet-based access, set both names. Custom CIDRs can be supplied in
addition to the subnet's resolved IPv4 address space:

```hcl
vpc         = "app-vpc"
subnet      = "app-subnet"
custom_cidr = ["192.168.1.0/24"]
```

See [`examples/basic`](./examples/basic) and
[`examples/complete`](./examples/complete) for runnable configurations.

## Inputs

| Name                | Description                                                                    | Type           | Required |
|---------------------|--------------------------------------------------------------------------------|----------------|----------|
| `cluster_name`      | Cluster display name; lowercase letters, digits, and hyphens only.              | `string`       | Yes      |
| `mariadb_version`   | MariaDB engine version, for example `10.6` or `11.8`; maps to provider `version`. | `string`       | Yes      |
| `database_name`     | Initial database name.                                                         | `string`       | Yes      |
| `mariadb_username`  | Admin username.                                                                | `string`       | Yes      |
| `password`          | Admin password; stored in Terraform state and not returned by the API.          | `string`       | Yes      |
| `compute_size`      | Flavor name from the MariaDB flavors catalog.                                  | `string`       | Yes      |
| `storage_size`      | Data volume size in whole GB; minimum 200.                                     | `number`       | Yes      |
| `availability_zone` | Availability zone code, for example `S1`.                                      | `string`       | Yes      |
| `vpc`               | VPC name used to resolve the subnet. Set with `subnet`.                        | `string`       | No*      |
| `subnet`            | Subnet name within the VPC. Set with `vpc`.                                    | `string`       | No*      |
| `custom_cidr`       | Custom client CIDRs. Set at least one CIDR unless both `vpc` and `subnet` are set. | `list(string)` | No*      |
| `description`       | Cluster description.                                                           | `string`       | No       |
| `high_availability` | Enables master-slave topology. Defaults to `false`.                            | `bool`         | No       |
| `num_replicas`      | Replica count; must be 1–10 when high availability is enabled.                 | `number`       | No       |
| `is_superuser`      | Whether the admin user is a superuser. Defaults to `false`.                    | `bool`         | No       |
| `network_type`      | Network type. Defaults to `private`.                                           | `string`       | No       |
| `storage_type`      | Storage class. Defaults to `High Performance`.                                 | `string`       | No       |
| `labels`            | Labels to assign to the cluster.                                               | `list(string)` | No       |
| `backup`            | Backup configuration; set to `null` to omit.                                   | `object`       | No       |
| `timeouts`          | Create and delete timeouts; provider default is 15 minutes.                   | `object`       | No       |

`*` Set `custom_cidr`, both `vpc` and `subnet`, or all three. VPC and subnet
names resolve the subnet's IPv4 address space; they do not select the
provisioned network.

The password must be 8–128 characters, include uppercase and lowercase letters,
a digit, and a special character, and must not contain `@`, `_`, or words from
`mariadb_username` or `cluster_name`.

When backup is enabled, `retention` (at least 1 day), `schedule_time` (`HH:MM`),
and `schedule_day` (`Monday` through `Sunday`) are required. The backup object's
`compression_level` defaults to `1`.

## Outputs

| Name                  | Description                                                |
|-----------------------|------------------------------------------------------------|
| `id`                  | Cluster UUID.                                              |
| `cluster_name`        | Configured cluster name.                                   |
| `version`             | MariaDB engine version.                                    |
| `database_name`       | Initial database name.                                     |
| `mariadb_username`    | Configured admin username.                                 |
| `users`               | Admin username returned by the API.                       |
| `status`              | Current cluster status.                                    |
| `topology`            | Resolved topology: `master` or `master-slave`.              |
| `num_replicas`        | Slave replica count.                                       |
| `availability_zone`   | Availability zone.                                         |
| `port`                | Database port.                                             |
| `created_at`          | Cluster creation timestamp.                                |
| `connection_string`   | Connection string; password is masked by the API.          |
| `backup_schedule_time`| Configured backup schedule time.                           |
| `backup_schedule_day` | Configured backup schedule day.                            |
| `mariadb`             | Selected cluster attributes for downstream modules.       |

## Important Notes

- Changes to the MariaDB resource configuration force a new cluster.
- `storage_size` must be a whole number of at least 200 GB.
- When `high_availability` is true, `num_replicas` must be between 1 and 10.
- The connection string is null until the cluster becomes `Active`.
- Import cannot populate `password` because the API does not return it.
