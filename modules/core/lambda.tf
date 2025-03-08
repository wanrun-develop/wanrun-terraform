#######################################################################
# wanrun server side rendering
#######################################################################
resource "aws_lambda_function" "internal_wanrun_ssr" {
  function_name = "${var.service_name}-${var.env}-internal-wanrun-ssr"
  description   = "Server Side Rendering"

  role    = aws_iam_role.wanrun_ssr.arn
  package_type = "Image"
  image_uri    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/lambda-initialize:latest"

  memory_size = "128"
  timeout = "60"

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = var.lambda_sg_ids
  }

  lifecycle {
    ignore_changes = [ image_uri ]
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
  provider = aws.virginia
  name     = "/aws/lambda/${var.service_name}-${var.env}-wanrun-ssr"
}
