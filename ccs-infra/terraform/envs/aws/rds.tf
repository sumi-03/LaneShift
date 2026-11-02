# sea 셀 DB (리전 이전의 출발지). Single-AZ 데모 구성 (기획서 ADR-15 초안)

resource "aws_db_subnet_group" "sea" {
  name       = "${var.name_prefix}-sea"
  subnet_ids = module.vpc.subnet_ids["data"]
  tags       = { Name = "${var.name_prefix}-sea" }
}

# 논리 복제(W6)를 위해 처음부터 켬. 재부팅이 필요한 값
resource "aws_db_parameter_group" "sea" {
  name   = "${var.name_prefix}-sea-pg17"
  family = "postgres17"

  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }
}

# 데이터 구간: 서비스 구간에서 5432만 허용
resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds"
  description = "sea cell DB: 5432 from service subnets only"
  vpc_id      = module.vpc.vpc_id
  tags        = { Name = "${var.name_prefix}-rds", Segment = "data" }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_service" {
  for_each          = toset(var.segments["service"].cidrs)
  security_group_id = aws_security_group.rds.id
  description       = "PostgreSQL from service subnet"
  ip_protocol       = "tcp"
  from_port         = 5432
  to_port           = 5432
  cidr_ipv4         = each.value
}

resource "aws_db_instance" "sea" {
  count = var.enable_rds ? 1 : 0

  identifier     = "${var.name_prefix}-sea"
  engine         = "postgres"
  engine_version = "17"
  instance_class = "db.t4g.micro"

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name                     = "ccs"
  username                    = "ccs_admin"
  manage_master_user_password = true # 비밀번호는 Secrets Manager에만, state에 남지 않음

  db_subnet_group_name   = aws_db_subnet_group.sea.name
  parameter_group_name   = aws_db_parameter_group.sea.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  tags = { Name = "${var.name_prefix}-sea", Segment = "data", Cell = "sea-aws" }
}
