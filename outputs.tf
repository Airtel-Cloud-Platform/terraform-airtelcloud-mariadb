output "id" {
  description = "UUID of the MariaDB cluster."
  value       = airtelcloud_mariadb.this.id
}

output "cluster_name" {
  description = "Configured cluster name."
  value       = airtelcloud_mariadb.this.cluster_name
}

output "version" {
  description = "MariaDB engine version."
  value       = airtelcloud_mariadb.this.version
}

output "database_name" {
  description = "Initial database name."
  value       = airtelcloud_mariadb.this.database_name
}

output "mariadb_username" {
  description = "Admin username for the MariaDB cluster."
  value       = airtelcloud_mariadb.this.mariadb_username
}

output "status" {
  description = "Current cluster status."
  value       = airtelcloud_mariadb.this.status
}

output "topology" {
  description = "Resolved topology (master or master-slave)."
  value       = airtelcloud_mariadb.this.topology
}

output "num_replicas" {
  description = "Number of slave replicas."
  value       = airtelcloud_mariadb.this.num_replicas
}

output "availability_zone" {
  description = "Availability zone of the cluster."
  value       = airtelcloud_mariadb.this.availability_zone
}

output "port" {
  description = "Database port returned by the API."
  value       = airtelcloud_mariadb.this.port
}

output "created_at" {
  description = "Creation timestamp of the cluster."
  value       = airtelcloud_mariadb.this.created_at
}

output "connection_string" {
  description = "MariaDB connection string. Empty until the cluster is Active. The API masks the password."
  value       = airtelcloud_mariadb.this.connection_string
  sensitive   = true
}

output "mariadb" {
  description = "Selected cluster attributes for downstream modules."
  sensitive   = true

  value = {
    id                = airtelcloud_mariadb.this.id
    cluster_name      = airtelcloud_mariadb.this.cluster_name
    version           = airtelcloud_mariadb.this.version
    database_name     = airtelcloud_mariadb.this.database_name
    mariadb_username  = airtelcloud_mariadb.this.mariadb_username
    status            = airtelcloud_mariadb.this.status
    topology          = airtelcloud_mariadb.this.topology
    num_replicas      = airtelcloud_mariadb.this.num_replicas
    availability_zone = airtelcloud_mariadb.this.availability_zone
    port              = airtelcloud_mariadb.this.port
    created_at        = airtelcloud_mariadb.this.created_at
    connection_string = airtelcloud_mariadb.this.connection_string
  }
}
