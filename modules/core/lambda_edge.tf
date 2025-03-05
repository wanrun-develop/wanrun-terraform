
#######################################################################
# wanrun server side rendering
#######################################################################
resource "aws_lambda_function" "wanrun_ssr" {
  provider      = aws.virginia
  function_name = "${var.service_name}-${var.env}-wanrun-ssr"
  description   = "Server Side Rendering"

  role    = aws_iam_role.wanrun_ssr.arn
  handler = "index.handler"
  runtime = "nodejs20.x"

  publish = true

  filename         = data.archive_file.wanrun_ssr.output_path
  source_code_hash = data.archive_file.wanrun_ssr.output_base64sha256
}

# NOTE: 別リポジトリでコード管理とCI/CDを置くため、temporary
data "archive_file" "wanrun_ssr" {
  type        = "zip"
  source_dir  = "${path.module}/function/temporary"
  output_path = "${path.module}/function/.zip/temporary.zip"
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
        "edgelambda.amazonaws.com",
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
