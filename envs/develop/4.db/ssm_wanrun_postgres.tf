####################################################################
# wanrun postgres information
####################################################################
resource "aws_ssm_parameter" "wanrun_postgres_password" {
  name        = "${local.ssm_parameter_store_prefix}/WANRUN/DB/POSTGRES_PASSWORD"
  description = "wanrun postgres password"
  type        = "SecureString"
  value       = "__dummy_value__"
  #   key_id = "" NOTE: kms運用したら追加

  tags = {
    Name = "${local.ssm_parameter_store_prefix}/WANRUN/DB/POSTGRES_PASSWORD"
  }
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "wanrun_postgres_user" {
  name        = "${local.ssm_parameter_store_prefix}/WANRUN/DB/POSTGRES_USER"
  description = "wanrun postgres user"
  type        = "String"
  value       = "wanrun"
  #   key_id = "" NOTE: kms運用したら追加

  tags = {
    Name = "${local.ssm_parameter_store_prefix}/WANRUN/DB/POSTGRES_USER"
  }
}

resource "aws_ssm_parameter" "wanrun_postgres_db" {
  name        = "${local.ssm_parameter_store_prefix}/WANRUN/DB/POSTGRES_DB"
  description = "wanrun postgres db"
  type        = "String"
  value       = "wanrun"
  #   key_id = "" NOTE: kms運用したら追加

  tags = {
    Name = "${local.ssm_parameter_store_prefix}/WANRUN/DB/POSTGRES_DB"
  }
}

resource "aws_ssm_parameter" "wanrun_postgres_host" {
  name        = "${local.ssm_parameter_store_prefix}/WANRUN/DB/POSTGRES_HOST"
  description = "wanrun postgres host"
  type        = "String"
  value       = module.db_ec2.wanrun_postgres_private_ip
  #   key_id = "" NOTE: kms運用したら追加

  tags = {
    Name = "${local.ssm_parameter_store_prefix}/WANRUN/DB/POSTGRES_HOST"
  }
}
