variable "alb_config" {
  description = "Configuration for the alb"
  type = object({
    name               = string
    internal           = bool
    load_balancer_type = string
    subnets            = list(string)
    enable_deletion_protection = bool
    security_groups = list(string)
  })
  default = null
}

variable "domain_name" {
  type        = string
}
