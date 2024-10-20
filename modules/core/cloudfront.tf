resource "aws_cloudfront_distribution" "web" {
  enabled = true

  # オリジンの設定
  origin {
    domain_name              = aws_s3_bucket.web.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.web.id
    origin_access_control_id = aws_cloudfront_origin_access_control.web.id
  }

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.web.id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    # 各policy設定
    response_headers_policy_id = aws_cloudfront_response_headers_policy.web.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.web.id
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  #   aliases = [
  #     var.web_front_domain
  #   ]

  is_ipv6_enabled     = true
  price_class         = "PriceClass_200" #PriceClass_100
  default_root_object = "index.html"
  #   web_acl_id          = var.front_web_waf_acl_id # 現状WAFなしで進める

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.cloudfront_acm_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  #   logging_config {
  #     include_cookies = false
  #     bucket          = "${var.service_name}-${var.env}-web-cloudfront-log"
  #     prefix          = "cloudfront/web/"
  #   }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 60
    response_page_path    = "/"
  }
}

resource "aws_cloudfront_response_headers_policy" "web" {
  name = "${var.service_name}-${var.env}-response-header-policy"
  security_headers_config {
    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }
  }
}

# オリジンリクエストポリシー
resource "aws_cloudfront_origin_request_policy" "web" {
  name = "${var.service_name}-${var.env}-web-custom-origin-request-policy"

  cookies_config {
    cookie_behavior = "none" # Cookieは転送しない
  }

  headers_config {
    header_behavior = "whitelist" # 指定されたヘッダーのみを転送
    headers {
      items = [
        "CloudFront-Is-Tablet-Viewer",
        "CloudFront-Is-Mobile-Viewer",
        "CloudFront-Is-SmartTV-Viewer",
        "CloudFront-Is-Android-Viewer",
        "CloudFront-Is-IOS-Viewer",
        "CloudFront-Is-Desktop-Viewer"
      ]
    }
  }

  query_strings_config {
    query_string_behavior = "all" # 全てのクエリ文字列を転送
  }
}

# OAC
resource "aws_cloudfront_origin_access_control" "web" {
  name                              = "${var.service_name}-${var.env}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
