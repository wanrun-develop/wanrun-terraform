
####################################################################
# wanrun
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
