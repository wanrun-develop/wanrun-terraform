// フロントエンド用
// TTL（有効期限）はデフォルトで1時間
data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

// バックエンド用
data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
