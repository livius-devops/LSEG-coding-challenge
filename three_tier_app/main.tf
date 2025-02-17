locals {
  #dev.json file saves all the vars need for deploy
  #change here in case another set of vars is needed
  config = jsondecode(file("dev.json"))
}

#deploys vpc, nat gw, igw, subnets
module "network" {
  source = "../modules/network"

  cidr_block = local.config.network.cidr_block
  subnets_public = local.config.network.subnets_public
  subnets_private = local.config.network.subnets_private
  subnets_db = local.config.network.subnets_db
}

#deploys sg attached to the load balancer
module "alb_sg" {
  source = "../modules/security_group"
  security_groups = {
    alb_sg = {
      name        = local.config.alb_sg.alb_sg.name
      description = local.config.alb_sg.alb_sg.description
      vpc_id      = module.network.vpc_id
      ingress     = local.config.alb_sg.alb_sg.ingress 
      egress      = local.config.alb_sg.alb_sg.egress 
    }
  }
}

#module for load balancer, target group, listeners (80 and 443) and acm cert attached
module "alb" {
  source = "../modules/alb"
  domain_name = "test.lseg.com"
  alb_config = {
    name                       = local.config.alb.alb_config.name
    internal                   = local.config.alb.alb_config.internal
    load_balancer_type         = local.config.alb.alb_config.load_balancer_type
    subnets                    = module.network.subnet_ids_public
    enable_deletion_protection = local.config.alb.alb_config.enable_deletion_protection
    security_groups            = module.alb_sg.sg_id
  }
}

#deploys sg attached to the ec2 that are running the backend
module "app_sg" {
  source = "../modules/security_group"
  security_groups = {
    alb_sg = {
      name        = local.config.app_sg.app_sg.name
      description = local.config.app_sg.app_sg.description
      vpc_id      = module.network.vpc_id
      ingress     = local.config.app_sg.app_sg.ingress 
      egress      = local.config.app_sg.app_sg.egress
    }
  }
}

#deploys auto-scaling group,launch template and the iam role to be attached to the ec2s 
module "asg" {
  source = "../modules/asg"

  asg = {
    name_prefix                = local.config.asg.asg.name_prefix
    image_id                   = local.config.asg.asg.image_id
    instance_type              = local.config.asg.asg.instance_type
    enable_deletion_protection = local.config.asg.asg.enable_deletion_protection
    vpc_security_group_ids     = module.app_sg.sg_id
    desired_capacity           = local.config.asg.asg.desired_capacity
    max_size                   = local.config.asg.asg.max_size
    min_size                   = local.config.asg.asg.min_size
    vpc_zone_identifier        = module.network.subnet_ids_private
  }
}

#deploys sg attached to the database
module "db_sg" {
  source = "../modules/security_group"
  security_groups = {
    alb_sg = {
      name        = local.config.db_sg.db_sg.name
      description = local.config.db_sg.db_sg.description
      vpc_id      = module.network.vpc_id
      ingress     = local.config.db_sg.db_sg.ingress 
      egress      = local.config.db_sg.db_sg.egress
    }
  }
}

#deploys an aurora postgres to be used by the backend services
module "rds" {
  source = "../modules/rds"
  config = {
    cluster_identifier      = local.config.rds.cluster_identifier
    engine_version          = local.config.rds.engine_version
    database_name           = local.config.rds.database_name
    master_username         = local.config.rds.master_username
    backup_retention_period = local.config.rds.backup_retention_period
    preferred_backup_window = local.config.rds.preferred_backup_window
    instance_count          = local.config.rds.instance_count
    instance_class          = local.config.rds.instance_class
    vpc_id                  = module.network.vpc_id
    subnet_ids              = module.network.subnet_ids_db
    vpc_security_group_ids  = module.db_sg.sg_id
  }
}

#deploys and cloudfront with s3 to server the static content from and separate action for alb backend 
#and also acm certificate needed for CF
module "frontend" {
  source = "../modules/frontend"

  cloudfront_s3_config = {
    s3_bucket_name                    = local.config.frontend.cloudfront_s3_config.s3_bucket_name
    default_root_object               = local.config.frontend.cloudfront_s3_config.default_root_object
    cloudfront_origin_access_identity = local.config.frontend.cloudfront_s3_config.cloudfront_origin_access_identity
    alb_dns_name                      = local.config.frontend.cloudfront_s3_config.alb_dns_name
    redirect_to_alb_path              = local.config.frontend.cloudfront_s3_config.redirect_to_alb_path
    domain_name                       = local.config.frontend.cloudfront_s3_config.domain_name
  }
}