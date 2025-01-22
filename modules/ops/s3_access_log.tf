###########################################
# ALB access log
###########################################
resource "aws_s3_bucket" "alb_access_log" {
  for_each = var.env == "prod" ? toset(["create"]) : toset([])

  bucket = "${var.service_name}-${var.env}-alb-access-log"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_access_log" {
  for_each = var.env == "prod" ? toset(["create"]) : toset([])

  bucket = aws_s3_bucket.alb_access_log[each.key].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_access_log" {
  for_each = var.env == "prod" ? toset(["create"]) : toset([])

  bucket = aws_s3_bucket.alb_access_log[each.key].id
  rule {
    id = "retention-rule"

    status = "Enabled"
    expiration {
      days = var.retention_period
    }
  }
}

resource "aws_s3_bucket_public_access_block" "alb_access_log" {
  for_each = var.env == "prod" ? toset(["create"]) : toset([])

  bucket                  = aws_s3_bucket.alb_access_log[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "alb_access_log" {
  for_each = var.env == "prod" ? toset(["create"]) : toset([])

  bucket = aws_s3_bucket.alb_access_log[each.key].id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Id" : "alb-access-log",
      "Statement" : [
        {
          "Sid" : "AWSConsoleStmt",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::582318560864:root"
          },
          "Action" : "s3:PutObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.alb_access_log[each.key].id}/*"
        },
        {
          "Sid" : "AWSLogDeliveryWrite",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "delivery.logs.amazonaws.com"
          },
          "Action" : "s3:PutObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.alb_access_log[each.key].id}/*",
          "Condition" : {
            "StringEquals" : {
              "s3:x-amz-acl" : "bucket-owner-full-control"
            }
          }
        },
        {
          "Sid" : "AWSLogDeliveryAclCheck",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "delivery.logs.amazonaws.com"
          },
          "Action" : "s3:GetBucketAcl",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.alb_access_log[each.key].id}"
        },
        {
          "Sid" : "DenyInsecureConnections",
          "Effect" : "Deny",
          "Principal" : "*",
          "Action" : "s3:*",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.alb_access_log[each.key].id}/*",
          "Condition" : {
            "Bool" : {
              "aws:SecureTransport" : "false"
            }
          }
        }
      ]
  })
}

###########################################
# Cloudfront log
###########################################
resource "aws_s3_bucket" "cloudfront_log" {
  for_each = var.env == "prod" ? toset(["create"]) : toset([])

  bucket = "${var.service_name}-${var.env}-cloudfront_log"
}


resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfront_log" {
  for_each = var.env == "prod" ? toset(["create"]) : toset([])

  bucket = aws_s3_bucket.cloudfront_log[each.key].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudfront_log" {
  for_each = var.env == "prod" ? toset(["create"]) : toset([])

  bucket = aws_s3_bucket.cloudfront_log[each.key].id
  rule {
    id = "retention-rule"

    status = "Enabled"
    expiration {
      days = var.retention_period
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudfront_log" {
  for_each = var.env == "prod" ? toset(["create"]) : toset([])

  bucket                  = aws_s3_bucket.cloudfront_log[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudfront_log" {
  for_each = var.env == "prod" ? toset(["create"]) : toset([])

  bucket = aws_s3_bucket.cloudfront_log[each.key].id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Id" : "cloudfront-log",
      "Statement" : [
        {
          "Action" : [
            "s3:PutBucketAcl",
            "s3:GetBucketAcl"
          ],
          "Effect" : "Allow",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.cloudfront_log[each.key].id}",
          "Principal" : {
            "AWS" : [
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            ]
          }
        },
        {
          "Sid" : "DenyInsecureConnections",
          "Effect" : "Deny",
          "Principal" : "*",
          "Action" : "s3:*",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.cloudfront_log[each.key].id}/*",
          "Condition" : {
            "Bool" : {
              "aws:SecureTransport" : "false"
            }
          }
        }
      ]
  })
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_log" {
  for_each = var.env == "prod" ? toset(["create"]) : toset([])

  bucket = aws_s3_bucket.cloudfront_log[each.key].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# awslogsdelivery https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
resource "aws_s3_bucket_acl" "cloudfront_log" {
  for_each = var.env == "prod" ? toset(["create"]) : toset([])

  depends_on = [aws_s3_bucket_ownership_controls.cloudfront_log]

  bucket = aws_s3_bucket.cloudfront_log[each.key].id
  acl    = "private"
}
