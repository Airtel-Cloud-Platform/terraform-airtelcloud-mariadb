terraform {
  required_providers {
    airtelcloud = {
      source  = "Airtel-Cloud-Platform/airtelcloud"
      version = ">= 2.0.0"
    }
  }
}

provider "airtelcloud" {
  api_endpoint = "https://south.cloud.airtel.in"
  api_key      = var.airtel_api_key
  api_secret   = var.airtel_api_secret
  region       = "south"
  organization = var.organization
  project_name = var.project_name
}

module "mariadb" {
  source = "../../"

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
