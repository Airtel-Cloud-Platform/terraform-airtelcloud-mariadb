# Airtel Cloud MariaDB Terraform Module

Terraform module for provisioning an Airtel Cloud MariaDB cluster using `airtelcloud_mariadb`.

v1 supports create, read, import, and delete. Changing configuration forces a new cluster. The API does not return the admin password; Terraform stores the configured value in state.

The installed provider must include the `airtelcloud_mariadb` resource.

## Features

- Creates a MariaDB cluster
- Optional high availability (master-slave) with replica count
- Optional backup schedule and protection plan
- Required security group CIDR allow list
- Optional labels
- Create and delete timeouts

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.5 |
| airtelcloud | >= 1.2.8, with `airtelcloud_mariadb` |

## Usage

### Basic Example

```hcl
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

  security_group = {
    allowed_ips = ["192.168.1.0/24"]
  }
}
```

### Complete Example

```hcl
module "mariadb" {
  source = "Airtel-Cloud-Platform/mariadb/airtelcloud"

  cluster_name      = "app-db"
  description       = "Application MariaDB cluster"
  mariadb_version   = "10.6"
  database_name     = "app"
  mariadb_username  = "dbadmin"
  password          = var.mariadb_password
  compute_size      = "db.maria.uhper.ccs.xlarge"
  storage_size      = 200
  availability_zone = "S1"
  high_availability = true
  num_replicas      = 1
  labels            = ["terraform"]

  backup = {
    enabled         = true
    protection_plan = "weekly-full-daily-incr"
    schedule_time   = "02:00"
    schedule_day    = "Monday"
  }

  security_group = {
    allowed_ips = ["192.168.1.0/24"]
  }

  timeouts = {
    create = "45m"
    delete = "30m"
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| cluster_name | Display name of the cluster | string | Yes |
| mariadb_version | MariaDB engine version | string | Yes |
| database_name | Initial database name | string | Yes |
| mariadb_username | Admin username | string | Yes |
| password | Admin password | string | Yes |
| compute_size | Flavor name | string | Yes |
| storage_size | Data volume size in GB (min 200) | number | Yes |
| availability_zone | Availability zone code | string | Yes |
| security_group | Allowed client CIDRs (`allowed_ips`) | object | Yes |
| description | Cluster description | string | No |
| high_availability | Master-slave topology | bool | No |
| num_replicas | Slave replica count | number | No |
| is_superuser | Admin superuser flag | bool | No |
| network_type | Network type (default `private`) | string | No |
| storage_type | Storage class (default `High Performance`) | string | No |
| labels | Labels to assign | list(string) | No |
| backup | Backup configuration | object | No |
| timeouts | Create and delete timeouts | object | No |

## Outputs

| Name | Description |
|------|-------------|
| id | Cluster UUID |
| cluster_name | Configured cluster name |
| version | MariaDB engine version |
| database_name | Initial database name |
| mariadb_username | Admin username |
| status | Current cluster status |
| topology | Resolved topology |
| num_replicas | Slave replica count |
| availability_zone | Availability zone |
| port | Database port |
| created_at | Creation timestamp |
| connection_string | Connection string (password masked by the API) |
| mariadb | Selected cluster attributes |

## Notes

- Configuration changes force a new cluster.
- When `high_availability` is true, `num_replicas` must be between 1 and 10.
- When `backup.enabled` is true, `schedule_time` (`HH:MM`) and `schedule_day` are required.
- Import cannot populate `password` because the API does not return it.
