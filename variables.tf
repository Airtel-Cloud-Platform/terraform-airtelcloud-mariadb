#########################################
# Identity
#########################################

variable "cluster_name" {
  description = "Display name of the MariaDB cluster. Forces a new resource."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cluster_name))
    error_message = "cluster_name must contain only lowercase letters, digits, and hyphens."
  }
}

variable "description" {
  description = "Cluster description. Forces a new resource. When empty, the API is sent an empty string."
  type        = string
  default     = ""
}

variable "mariadb_version" {
  description = "MariaDB engine version (for example 10.6, 10.11, 11.4, or 11.8). Forces a new resource."
  type        = string

  validation {
    condition     = length(trim(var.mariadb_version, " ")) > 0
    error_message = "mariadb_version cannot be empty."
  }
}

#########################################
# Database credentials
#########################################

variable "database_name" {
  description = "Name of the initial database. Forces a new resource."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.database_name))
    error_message = "database_name must start with a letter and contain only letters, digits, and underscore."
  }
}

variable "mariadb_username" {
  description = "Admin username for the cluster. Forces a new resource."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.mariadb_username))
    error_message = "mariadb_username must start with a letter and contain only letters, digits, and underscore."
  }
}

variable "password" {
  description = "Admin password. Stored in Terraform state; the API does not return it. Forces a new resource."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.password) >= 8 && length(var.password) <= 128
    error_message = "password must be between 8 and 128 characters."
  }

  validation {
    condition = (
      can(regex("[A-Z]", var.password)) &&
      can(regex("[a-z]", var.password)) &&
      can(regex("[0-9]", var.password)) &&
      can(regex("[^A-Za-z0-9]", var.password))
    )
    error_message = "password must contain uppercase, lowercase, digit, and special characters."
  }

  validation {
    condition     = !strcontains(var.password, "@") && !strcontains(var.password, "_")
    error_message = "password cannot contain '@' or '_'."
  }

  validation {
    condition = alltrue([
      for word in concat(
        [var.cluster_name, var.mariadb_username],
        regexall("[A-Za-z0-9]+", var.cluster_name),
        regexall("[A-Za-z0-9]+", var.mariadb_username)
      ) : length(word) < 3 || !strcontains(lower(var.password), lower(word))
    ])
    error_message = "password cannot contain words from mariadb_username or cluster_name."
  }
}

variable "is_superuser" {
  description = "Whether the admin user is a superuser. Defaults to false. Forces a new resource."
  type        = bool
  default     = false
}

#########################################
# Sizing and placement
#########################################

variable "compute_size" {
  description = "Flavor name from the mariadb flavors catalog (for example db.maria.uhper.ccs.xlarge). Forces a new resource."
  type        = string

  validation {
    condition     = length(trim(var.compute_size, " ")) > 0
    error_message = "compute_size cannot be empty."
  }
}

variable "storage_size" {
  description = "Data volume size in GB. Must be at least 200. Forces a new resource."
  type        = number

  validation {
    condition     = var.storage_size >= 200 && floor(var.storage_size) == var.storage_size
    error_message = "storage_size must be a whole number of at least 200 GB."
  }
}

variable "storage_type" {
  description = "Storage class label from the volume-types catalog. Defaults to High Performance. Forces a new resource."
  type        = string
  default     = "High Performance"
}

variable "availability_zone" {
  description = "Availability zone code (for example S1). Forces a new resource."
  type        = string

  validation {
    condition     = length(trim(var.availability_zone, " ")) > 0
    error_message = "availability_zone cannot be empty."
  }
}

variable "network_type" {
  description = "Network type for the cluster. Defaults to private. Forces a new resource."
  type        = string
  default     = "private"
}

#########################################
# High availability
#########################################

variable "high_availability" {
  description = "When true, creates master-slave topology. Defaults to false. Forces a new resource."
  type        = bool
  default     = false
}

variable "num_replicas" {
  description = "Slave replica count. Required and must be between 1 and 10 when high_availability is true. Defaults to 0. Forces a new resource."
  type        = number
  default     = 0

  validation {
    condition     = var.num_replicas >= 0 && var.num_replicas <= 10 && floor(var.num_replicas) == var.num_replicas
    error_message = "num_replicas must be a whole number between 0 and 10."
  }

  validation {
    condition     = !var.high_availability || (var.num_replicas >= 1 && var.num_replicas <= 10)
    error_message = "num_replicas is required when high_availability is true and must be between 1 and 10."
  }
}

#########################################
# Optional extras
#########################################

variable "labels" {
  description = "Labels to assign to the cluster. Forces a new resource."
  type        = list(string)
  default     = null
}

variable "vpc" {
  description = "VPC name used to resolve the subnet. Set together with subnet."
  type        = string
  default     = null

  validation {
    condition     = var.vpc == null || length(trim(var.vpc, " ")) > 0
    error_message = "vpc cannot be empty when set."
  }
}

variable "subnet" {
  description = "Subnet name within the VPC. Set together with vpc."
  type        = string
  default     = null

  validation {
    condition     = var.subnet == null || length(trim(var.subnet, " ")) > 0
    error_message = "subnet cannot be empty when set."
  }
}

variable "custom_cidr" {
  description = "Custom client CIDRs. Required unless both vpc and subnet are set; can be combined with them."
  type        = list(string)
  default     = null

  validation {
    condition = var.custom_cidr == null || alltrue([
      for cidr in var.custom_cidr : length(trim(cidr, " ")) > 0
    ])
    error_message = "custom_cidr cannot contain empty values."
  }

  validation {
    condition = (
      (var.vpc == null) == (var.subnet == null) &&
      (
        (var.custom_cidr != null && length(var.custom_cidr) > 0) ||
        (var.vpc != null && var.subnet != null)
      )
    )
    error_message = "Set custom_cidr, both vpc and subnet, or all three."
  }
}

variable "backup" {
  description = "Backup configuration. Forces a new resource. Set to null to omit."

  type = object({
    enabled           = optional(bool, false)
    protection_plan   = optional(string)
    compression_level = optional(number, 1)
    retention         = optional(number)
    schedule_time     = optional(string)
    schedule_day      = optional(string)
  })

  default = null

  validation {
    condition = (
      var.backup == null ||
      !try(var.backup.enabled, false) ||
      (
        try(var.backup.schedule_time, null) != null &&
        try(var.backup.schedule_day, null) != null &&
        try(var.backup.retention, null) != null &&
        try(var.backup.retention, 0) >= 1
      )
    )
    error_message = "schedule_time, schedule_day, and retention (at least 1 day) are required when backup.enabled is true."
  }

  validation {
    condition = (
      var.backup == null ||
      try(var.backup.schedule_time, null) == null ||
      can(regex("^([01]\\d|2[0-3]):([0-5]\\d)$", var.backup.schedule_time))
    )
    error_message = "backup.schedule_time must be in HH:MM format."
  }

  validation {
    condition = (
      var.backup == null ||
      try(var.backup.schedule_day, null) == null ||
      contains(
        ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
        var.backup.schedule_day
      )
    )
    error_message = "backup.schedule_day must be Monday through Sunday."
  }

  validation {
    condition = (
      var.backup == null ||
      try(var.backup.retention, null) == null ||
      (
        var.backup.retention >= 1 &&
        floor(var.backup.retention) == var.backup.retention
      )
    )
    error_message = "backup.retention must be a whole number of at least 1 day when set."
  }

  validation {
    condition = (
      var.backup == null ||
      floor(try(var.backup.compression_level, 1)) == try(var.backup.compression_level, 1)
    )
    error_message = "backup.compression_level must be a whole number."
  }
}

variable "timeouts" {
  description = "Create and delete timeouts for the MariaDB cluster."

  type = object({
    create = optional(string)
    delete = optional(string)
  })

  default = null
}
