resource "airtelcloud_mariadb" "this" {
  cluster_name      = var.cluster_name
  description       = var.description
  version           = var.mariadb_version
  database_name     = var.database_name
  mariadb_username  = var.mariadb_username
  password          = var.password
  compute_size      = var.compute_size
  storage_size      = var.storage_size
  availability_zone = var.availability_zone
  high_availability = var.high_availability
  num_replicas      = var.num_replicas
  is_superuser      = var.is_superuser
  network_type      = var.network_type
  storage_type      = var.storage_type
  labels            = var.labels
  security_group = {
    allowed_ips = var.security_group.allowed_ips
  }
  backup = var.backup

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = try(timeouts.value.create, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
