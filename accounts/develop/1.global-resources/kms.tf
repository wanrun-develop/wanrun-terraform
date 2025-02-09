#######################################################################
# kms
# NOTE: 必要になったらコメントを外して運用
#######################################################################
# resource "aws_kms_alias" "main" {
#   name          = "alias/global-${var.service_name}"
#   target_key_id = aws_kms_key.main.key_id
# }

# resource "aws_kms_key" "main" {
#   policy = jsonencode(
#     {
#       "Version" : "2012-10-17",
#       "Id" : "global-kms",
#       "Statement" : [
#         {
#           "Sid" : "Enable IAM User Permissions",
#           "Effect" : "Allow",
#           "Principal" : {
#             "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
#           },
#           "Action" : "kms:*",
#           "Resource" : "*"
#         },
#         {
#           Sid    = "Allow administration of the key"
#           Effect = "Allow"
#           Principal = {
#             AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/kazuya"
#           },
#           Action = [
#             "kms:ReplicateKey",
#             "kms:Create*",
#             "kms:Describe*",
#             "kms:Enable*",
#             "kms:List*",
#             "kms:Put*",
#             "kms:Update*",
#             "kms:Revoke*",
#             "kms:Disable*",
#             "kms:Get*",
#             "kms:Delete*",
#             "kms:ScheduleKeyDeletion",
#             "kms:CancelKeyDeletion"
#           ],
#           Resource = "*"
#         },
#         {
#           Sid    = "Allow use of the key"
#           Effect = "Allow"
#           Principal = {
#             AWS = [
#               "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/wakasugi",
#               "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/yukawa"
#             ]
#           },
#           Action = [
#             "kms:DescribeKey",
#             "kms:Encrypt",
#             "kms:Decrypt",
#             "kms:ReEncrypt*",
#             "kms:GenerateDataKey",
#             "kms:GenerateDataKeyWithoutPlaintext"
#           ],
#           Resource = "*"
#         }
#       ]
#   })
# }
