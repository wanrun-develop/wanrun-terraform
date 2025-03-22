
####################################################################
# wanrun secret key
####################################################################
resource "aws_ssm_parameter" "wanrun_secret_key" {
  name        = "${var.ssm_prefix}/WANRUN/SECRET_KEY"
  description = "wanrun secret key"
  type        = "SecureString"
  value       = "__dummy_value__"
  #   key_id = "" NOTE: kms運用したら追加

  tags = {
    Name = "${var.ssm_prefix}/WANRUN/SECRET_KEY"
  }
  lifecycle {
    ignore_changes = [value]
  }
}

####################################################################
# wanrun google place api key
####################################################################
resource "aws_ssm_parameter" "wanrun_google_place_api_key" {
  name        = "${var.ssm_prefix}/WANRUN/GOOGLE_PLACE_API_KEY"
  description = "wanrun google place api key"
  type        = "SecureString"
  value       = "__dummy_value__"
  #   key_id = "" NOTE: kms運用したら追加

  tags = {
    Name = "${var.ssm_prefix}/WANRUN/GOOGLE_PLACE_API_KEY"
  }
  lifecycle {
    ignore_changes = [value]
  }
}


