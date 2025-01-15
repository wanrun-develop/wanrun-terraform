####################################################################
# IAM Instance Profile
####################################################################
resource "aws_iam_instance_profile" "postgres_main_db" {
  name = aws_iam_role.postgres_main_db.name
  role = aws_iam_role.postgres_main_db.name
}

resource "aws_iam_role" "postgres_main_db" {
  name               = "${var.service_name}-${var.env}-main-db"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2.json
}

data "aws_iam_policy_document" "ec2" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "postgres_main_db" {
  name   = "${var.service_name}-${var.env}-main-db"
  policy = data.aws_iam_policy_document.postgres_main_db.json
  path   = "/"
}

resource "aws_iam_role_policy_attachment" "postgres_main_db_1" {
  role       = aws_iam_role.postgres_main_db.name
  policy_arn = aws_iam_policy.postgres_main_db.arn
}

data "aws_iam_policy_document" "postgres_main_db" {
  version = "2012-10-17"
  statement {
    sid    = "SessionMangers"
    effect = "Allow"
    actions = [
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }
}
