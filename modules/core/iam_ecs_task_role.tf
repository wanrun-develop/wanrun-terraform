###########################################
# iam role (ecs task role)
###########################################
resource "aws_iam_role" "wanrun_ecs_task_role" {
  name        = "${var.service_name}-${var.env}-ecs-task-role"
  description = "EcsTaskRole"
  assume_role_policy = jsonencode(
    {
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          }
        }
      ],
      "Version" : "2012-10-17"
  })
}

resource "aws_iam_policy" "ecs_exec" {
  name        = "${var.service_name}-${var.env}-ecs-exec-policy"
  path        = "/"
  description = "EcsExec"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
          ],
          "Resource" : "*"
        }
      ]
  })
}

resource "aws_iam_policy" "wanrun_ecs_task_role_policy" {
  name = "${var.service_name}-${var.env}-task-role-policy"
  path = "/"

  policy = jsonencode(
    {
      "Sid" : "s3",
      "Effect" : "Allow",
      "Action" : [
        "s3:List*",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource" : [
        "${aws_s3_bucket.cms.arn}",
        "${aws_s3_bucket.cms.arn}/*"
      ]
    },
    {
      "Sid" : "KMSPolicy",
      "Effect" : "Allow",
      "Action" : [
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource" : "${var.kms_key_arn}"
    }
  )
}

resource "aws_iam_role_policy_attachment" "wanrun_ecs_task_role_1" {
  for_each = var.env == "develop" ? toset(["create"]) : toset([])

  policy_arn = aws_iam_policy.ecs_exec.arn
  role       = aws_iam_role.wanrun_ecs_task_role.name
}

resource "aws_iam_role_policy_attachment" "wanrun_ecs_task_role_2" {
  policy_arn = aws_iam_policy.wanrun_ecs_task_role_policy.arn
  role       = aws_iam_role.wanrun_ecs_task_role.name
}
