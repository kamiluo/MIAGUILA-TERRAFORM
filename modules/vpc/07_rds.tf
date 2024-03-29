##########################################################################
#--RDS
##########################################################################
#---------POSTGRES RDS
resource "aws_db_instance" "rds_ma_postgres" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "10.9"
  instance_class       = "${var.rds_instance_postgres_type}"
  name                 = "prod_postgres_db"
  username             = "demouser"
  password             = "password"
  identifier           = "rds-ma-postgres"
  snapshot_identifier  = "snap-id-postgres"
  skip_final_snapshot  = true
}

#---------POSTGRES RDS DWH
resource "aws_db_instance" "rds_ma_dwh" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "10.9"
  instance_class       = "${var.rds_instance_dwh_type}"
  name                 = "dwh_postgres_db"
  username             = "demouser"
  password             = "password"
  identifier           = "rds-ma-dwh"
  snapshot_identifier  = "snap-id-dwh"
  skip_final_snapshot  = true
}