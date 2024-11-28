# カスタムヘッダー用のランダムな文字列生成
resource "random_string" "cloudfront_header" {
  length  = 16    // 長さを指定
  special = false // 特殊文字を含まない
  upper   = true  // 大文字を含む
  lower   = true  // 小文字を含む
  numeric = true  // 数字を含む
}

###########################################
# cloudfront
###########################################
resource "aws_ssm_parameter" "cloudfront_access_control_header_value" {
  name        = "${var.ssm_parameter_store_prefix}/CLOUDFRONT/ACCESS_CONTROL_HEADER/VALUE"
  description = "For cloudfront access control header value"
  type        = "SecureString"
  key_id      = var.kms_key_arn
  value       = random_string.cloudfront_header.result
  lifecycle {
    ignore_changes = [value]
  }
}
