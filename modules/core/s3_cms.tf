#######################################################################
# cms
#######################################################################
resource "aws_s3_bucket" "cms" {
  bucket = "${var.service_name}-${var.env}-cms"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cms" {
  bucket = aws_s3_bucket.cms.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cms" {
  bucket                  = aws_s3_bucket.cms.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "cms" {
  bucket = aws_s3_bucket.cms.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cms" {
  bucket = aws_s3_bucket.cms.id
  rule {
    id     = "rotate-files-after-1year"
    status = "Enabled"

    expiration {
      days = var.retention_period // オブジェクトの生成と更新日からx日後に削除
    }
  }

  rule {
    id     = "noncurrent-expire-rule"
    status = "Enabled"

    noncurrent_version_expiration {
      newer_noncurrent_versions = 1 // 非現行バージョンを1日で消す
      noncurrent_days           = 1
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

resource "aws_s3_bucket_versioning" "cms" {
  bucket = aws_s3_bucket.cms.id
  versioning_configuration {
    status = "Disabled" // 運用として不要なため
  }
}

data "aws_iam_policy_document" "cms" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]
    resources = [
      "${aws_s3_bucket.cms.arn}/*",
      "${aws_s3_bucket.cms.arn}"
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.wanrun_ecs_task_role.arn
      ]
    }
  }

  statement {
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.cms.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "cms" {
  bucket = aws_s3_bucket.cms.id
  policy = data.aws_iam_policy_document.cms.json
}
