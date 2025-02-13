variable "config" {
  type = object({
    cluster_identifier     = string
    engine_version         = string
    database_name          = string
    master_username        = string
    backup_retention_period = number
    preferred_backup_window = string
    instance_count         = number
    instance_class         = string
    vpc_id                = string
    subnet_ids            = list(string)
    vpc_security_group_ids = list(string)
  })
}

