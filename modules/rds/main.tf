resource "random_password" "aurora_master_password" {
  length           = 16
  special          = true
  override_special = "!@#"
}

resource "aws_secretsmanager_secret" "aurora_master_password" {
  name        = "aurora-master-password"
  description = "Master password for Aurora PostgreSQL"
}

resource "aws_secretsmanager_secret_version" "aurora_master_password_version" {
  secret_id     = aws_secretsmanager_secret.aurora_master_password.id
  secret_string = random_password.aurora_master_password.result
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = var.config.cluster_identifier
  engine                 = "aurora-postgresql"
  engine_version         = var.config.engine_version
  database_name          = var.config.database_name
  master_username        = var.config.master_username
  master_password        = aws_secretsmanager_secret.aurora_master_password.arn
  backup_retention_period = var.config.backup_retention_period
  preferred_backup_window = var.config.preferred_backup_window
  vpc_security_group_ids  = var.config.vpc_security_group_ids
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  storage_encrypted       = true
  apply_immediately       = true
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count                = var.config.instance_count
  identifier           = "${var.config.cluster_identifier}-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.aurora.id
  instance_class       = var.config.instance_class
  engine              = "aurora-postgresql"
  publicly_accessible = false
}


resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = var.config.subnet_ids
}

