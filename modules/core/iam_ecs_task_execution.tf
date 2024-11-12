###########################################
# iam role (ecs exection)
###########################################
resource "aws_iam_role" "ecs_task_execution_common" {
  name        = "${var.service_name}-${var.env}-ecsTaskExecutionRole-common"
  description = "EcsTaskExecutionRole"
  assume_role_policy = jsonencode(
    {
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          },
          "Sid" : "ecs execution"
        }
      ],
      "Version" : "2008-10-17"
  })
}

resource "aws_iam_policy" "ecs_task_execution_common" {
  name        = "${var.service_name}-${var.env}-ecsTaskExecutionRole-policy-common"
  path        = "/"
  description = "EcsTaskExecutionRole policy"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "KMSPolicy",
          "Effect" : "Allow",
          "Action" : "kms:Decrypt",
          "Resource" : "${var.kms_key_arn}"
        }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_common_1" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_common.name
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_common_2" {
  policy_arn = aws_iam_policy.ecs_task_execution_common.arn
  role       = aws_iam_role.ecs_task_execution_common.name
}
