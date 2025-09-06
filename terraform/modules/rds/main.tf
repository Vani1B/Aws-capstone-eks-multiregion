
  ############################################
# modules/rds/main.tf  (AWS provider v5.x)
############################################

locals {
  common_tags = merge(var.tags, {
    Module    = "rds"
    Component = "database"
  })
}

# -----------------------------------------
# DB subnet group (private subnets only)
# -----------------------------------------
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.name}-subnets"
  subnet_ids = var.private_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.name}-subnets"
  })
}

# -----------------------------------------
# Security group (only EKS nodes may connect)
# -----------------------------------------
resource "aws_security_group" "rds" {
  name        = "${var.name}-rds-sg"
  description = "RDS MySQL access from EKS node security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EKS node SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.allowed_sg_id] # pass module.eks.node_security_group_id
  }

  egress {
    description = "All egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.name}-rds-sg"
  })
}

# -----------------------------------------
# (Optional) Parameter group (example stub)
# -----------------------------------------
# resource "aws_db_parameter_group" "mysql" {
#   name   = "${var.name}-mysql-pg"
#   family = "mysql8.0"
#   tags   = merge(local.common_tags, { Name = "${var.name}-mysql-pg" })
#
#   # Example:
#   # parameter {
#   #   name  = "slow_query_log"
#   #   value = "1"
#   # }
# }

# -----------------------------------------
# DB instance (MySQL)
# -----------------------------------------
resource "aws_db_instance" "mysql" {
  identifier               = "${var.name}-mysql"

  engine                   = "mysql"
  engine_version           = var.engine_version       # e.g., "8.0.39"
  instance_class           = var.instance_class       # e.g., "db.t3.micro"

  allocated_storage        = var.allocated_storage    # e.g., 20
  storage_type             = "gp3"
  storage_encrypted        = true

  username                 = var.db_username
  password                 = var.db_password          # provided via Secrets Manager/random_password

  db_subnet_group_name     = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids   = [aws_security_group.rds.id]

  publicly_accessible      = false
  multi_az                 = false

  # If using a custom parameter group, uncomment:
  # parameter_group_name     = aws_db_parameter_group.mysql.name

  # ---- Ops / lifecycle (AWS provider v5.x names) ----
  backup_retention_period  = 7
  backup_window            = "02:00-03:00"            # v5.x (was preferred_backup_window)
  maintenance_window       = "sun:03:00-sun:04:00"
  deletion_protection      = false
  skip_final_snapshot      = true
  apply_immediately        = true

  tags = merge(local.common_tags, {
    Name   = "${var.name}-mysql"
    Engine = "mysql"
  })
}
