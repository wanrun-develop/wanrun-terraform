#######################################################################
# lambda wanrun server side rendering
# NOTE: https://qiita.com/j2-yano/items/3aba0f546820927b70c7
#######################################################################
resource "aws_lambda_function" "internal_wanrun_ssr" {
  function_name = "${var.service_name}-${var.env}-internal-wanrun-ssr"
  description   = "Server Side Rendering"

  role         = aws_iam_role.wanrun_ssr.arn
  package_type = "Image"
  image_uri    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${var.service_name}-global-lambda-initialize:latest"

  memory_size = "128"
  timeout     = "60"

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = var.lambda_sg_ids
  }

  environment {
    variables = {
      "AWS_LWA_ENABLE_COMPRESSION" = "true"
      "NODE_ENV"                   = "production"
      "PORT"                       = "3000"
    }
  }

  lifecycle {
    ignore_changes = [image_uri]
  }
}

resource "aws_lambda_function_url" "internal_wanrun_ssr" {
  function_name      = aws_lambda_function.internal_wanrun_ssr.function_name
  authorization_type = "AWS_IAM"
}

resource "aws_lambda_permission" "internal_wanrun_ssr" {
  statement_id  = "AllowCloudFrontServicePrincipal"
  action        = "lambda:InvokeFunctionUrl"
  function_name = aws_lambda_function.internal_wanrun_ssr.function_name
  principal     = "cloudfront.amazonaws.com"
  source_arn    = aws_cloudfront_distribution.main.arn
}

#######################################################################
# ecr wanrun server side rendering
#######################################################################
resource "aws_ecr_repository" "internal_wanrun_ssr" {
  name = "${var.service_name}-${var.env}-internal-wanrun-ssr"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

data "aws_ecr_lifecycle_policy_document" "internal_wanrun_ssr" {
  rule {
    priority    = 1
    description = "Only keep untagged images for 1 day."

    selection {
      tag_status   = "untagged"
      count_type   = "sinceImagePushed"
      count_number = 1
      count_unit   = "days"
    }
    action {
      type = "expire"
    }
  }
  rule {
    priority    = 2
    description = "Only keep ${var.lambda_ssr_retention_image_count} images for application repositories."

    selection {
      tag_status   = "any"
      count_type   = "imageCountMoreThan"
      count_number = var.lambda_ssr_retention_image_count
    }
    action {
      type = "expire"
    }
  }
}

resource "aws_ecr_lifecycle_policy" "internal_wanrun_ssr" {
  repository = aws_ecr_repository.internal_wanrun_ssr.name
  policy     = data.aws_ecr_lifecycle_policy_document.internal_wanrun_ssr.json
}

#######################################################################
# iam wanrun server side rendering
#######################################################################
data "aws_iam_policy_document" "lambda_edge_assume_role_policy" {
  statement {
    sid    = "AllowCloudFrontEdge"
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "wanrun_ssr" {
  name               = "${var.service_name}-${var.env}-wanrun-ssr-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_edge_assume_role_policy.json
}

data "aws_iam_policy_document" "wanrun_ssr" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:GetFunction",
      "lambda:EnableReplication",
      "cloudfront:UpdateDistribution"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "wanrun_ssr" {
  name   = "${var.service_name}-${var.env}-wanrun-ssr-policy"
  role   = aws_iam_role.wanrun_ssr.id
  policy = data.aws_iam_policy_document.wanrun_ssr.json
}

#######################################################################
# cloudwatch log wanrun server side rendering
#######################################################################
resource "aws_cloudwatch_log_group" "wanrun_ssr" {
  name       = "/aws/lambda/${aws_lambda_function.internal_wanrun_ssr.function_name}"
  depends_on = [aws_lambda_function.internal_wanrun_ssr]
}
