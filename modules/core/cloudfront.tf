locals {
  backend_origin_id = "gateway"
}
#######################################################################
# wanrun
#######################################################################
resource "aws_cloudfront_distribution" "main" {
  enabled = true

  ### フロントエンドの定義
  origin {
    domain_name              = aws_s3_bucket.web.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.web.id
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.web.id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    # 各policy設定
    response_headers_policy_id = aws_cloudfront_response_headers_policy.frontend.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.frontend.id
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
  }

  ### gateway側
  origin {
    domain_name = aws_lb.internal_gateway.dns_name
    origin_id   = local.backend_origin_id
    // vpc origin
    vpc_origin_config {
      vpc_origin_id = aws_cloudfront_vpc_origin.main_internal_alb.id
    }

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "http-only" // vpc originのため
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 60
      origin_read_timeout      = 60
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/gateway/*"
    target_origin_id       = local.backend_origin_id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "DELETE", "PATCH"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = false

    # 各policy設定
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.gateway.id
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_disabled.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.gateway.id
  }

  ### 共通
  #   aliases = [
  #     var.main_domain
  #   ]

  is_ipv6_enabled     = true
  price_class         = "PriceClass_200" // PriceClass_100
  default_root_object = "index.html"
  #   web_acl_id          = var.main_waf_acl_id // 現状WAFなしで進める

  // 国の指定
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = var.whitelist_locations
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.cloudfront_acm_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  // NOTE: 本番だけログあり
  dynamic "logging_config" {
    for_each = var.env == "prod" ? toset(["create"]) : toset([])
    content {
      include_cookies = false
      bucket          = "${var.service_name}-${var.env}-main-cloudfront-log"
      prefix          = "cloudfront/main/"
    }
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 60
    response_page_path    = "/"
  }
}


#######################################################################
# フロントエンドがoriginの設定
#######################################################################
resource "aws_cloudfront_response_headers_policy" "frontend" {
  name = "${var.service_name}-${var.env}-frontend-res-header-policy"
  security_headers_config {
    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }
    # Strict-Transport-Security: HTTPSを強制
    dynamic "strict_transport_security" {
      for_each = var.env == "prod" ? toset(["create"]) : toset([]) // 本番環境のみ有効化
      content {
        access_control_max_age_sec = 63072000 // 2年間
        include_subdomains         = true     // サブドメインを含めるか
        preload                    = true     // ドメインをHSTSプリロードリストに登録するよう要求
        override                   = true
      }
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin" // オリジン情報のみが送信
      override        = true
    }

    # X-Content-Type-Options: コンテンツタイプのスニッフィングを防止
    content_type_options {
      override = true
    }

    # X-XSS-Protection: 古いブラウザでのXSS攻撃を防止
    xss_protection {
      protection = true
      mode_block = true // 攻撃が検出された場合、ページをブロック
      override   = true
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "frontend" {
  name = "${var.service_name}-${var.env}-frontend-custom-origin-req-policy"

  cookies_config {
    cookie_behavior = "none" // Cookieは転送しない
  }

  headers_config {
    header_behavior = "whitelist" // 指定されたヘッダーのみを転送
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
    query_string_behavior = "all" // 全てのクエリ文字列を転送
  }
}

# OAC
resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = "${var.service_name}-${var.env}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#######################################################################
# バックエンドがoriginの設定
#######################################################################
resource "aws_cloudfront_response_headers_policy" "gateway" {
  name = "${var.service_name}-${var.env}-gateway-res-header-policy"
  security_headers_config {
    # X-Frame-Options: クロスオリジンのiframe埋め込みを制御
    frame_options {
      frame_option = "SAMEORIGIN"
      override     = true
    }

    # X-Content-Type-Options: コンテンツタイプのスニッフィングを防止
    content_type_options {
      override = true
    }

    # Strict-Transport-Security: HTTPSを強制
    dynamic "strict_transport_security" {
      for_each = var.env == "prod" ? toset(["create"]) : toset([]) // 本番環境のみ有効化
      content {
        access_control_max_age_sec = 63072000 // 2年間
        include_subdomains         = true     // サブドメインを含めるか
        preload                    = true     // ドメインをHSTSプリロードリストに登録するよう要求
        override                   = true
      }
    }

    # Referrer-Policy: リファラー情報の共有を制御
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin" //同一オリジン内では完全なリファラー情報を共有し、クロスオリジンでは最小限の情報を送信
      override        = false                             //上書きはしない
    }

    # X-XSS-Protection: 古いブラウザでのXSS攻撃を防止
    xss_protection {
      protection = true
      mode_block = true // 攻撃が検出された場合、ページをブロック
      override   = true
    }
  }

  cors_config {
    # 許可するヘッダー
    access_control_allow_headers {
      items = [
        "Authorization",
        "Content-Type"
      ]
    }

    # 許可するHTTPメソッド
    access_control_allow_methods {
      items = [
        "GET",
        "POST",
        "PUT",
        "DELETE",
        "OPTIONS"
      ]
    }

    # 許可するオリジン
    access_control_allow_origins {
      items = var.access_control_allow_origins
    }

    # その他のCORS設定
    access_control_allow_credentials = false // クッキーや認証情報を許可する場合は true
    origin_override                  = true  // オリジンヘッダーを上書き
  }
}

resource "aws_cloudfront_origin_request_policy" "gateway" {
  name = "${var.service_name}-${var.env}-gateway-custom-origin-req-policy"

  cookies_config {
    cookie_behavior = "none" // Cookieは転送しない
  }

  headers_config {
    header_behavior = "whitelist" // 指定されたヘッダーのみを転送
    headers {
      items = [
        # "CloudFront-Is-Tablet-Viewer",
        # "CloudFront-Is-Mobile-Viewer",
        # "CloudFront-Is-SmartTV-Viewer",
        # "CloudFront-Is-Android-Viewer",
        # "CloudFront-Is-IOS-Viewer",
        # "CloudFront-Is-Desktop-Viewer",
        "Authorization",
        "Content-Type",
        "Referer"
      ]
    }
  }

  query_strings_config {
    query_string_behavior = "all" // 全てのクエリ文字列を転送
  }
}
