variable "cidr_block" {
  type        = string
}

variable "subnets_public" {
  description = "Map of subnet configurations for public use"
  type        = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "subnets_private" {
  description = "Map of subnet configurations for private use"
  type        = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "subnets_db" {
  description = "Map of subnet configurations for db use"
  type        = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}
