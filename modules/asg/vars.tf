
variable "asg" {
  description = "Configuration for the asg"
  type = object({
    name_prefix                = string
    image_id                   = string
    instance_type              = string
    enable_deletion_protection = bool
    vpc_security_group_ids     = list(string)
    desired_capacity           = number
    max_size                   = number
    min_size                   = number
    vpc_zone_identifier        = list(string)
  })
  default = null
}
