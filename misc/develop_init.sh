###########################################
# s3とDynamoDB作成用のスクリプト
# これらのリソースは、terraformの管理対象外のため手動作成する
###########################################

#!/bin/bash

ORG_NAME="wanrun"
REGION="ap-northeast-1"
ENV="develop"
AWS_ACCOUNT_ID="140023401081"
BUCKET_NAME="$ORG_NAME-$ENV-$AWS_ACCOUNT_ID-terraform-tfstate"
DYNAMODB_TABLE="$ORG_NAME-terraform-state-lock"
# PROFILE_NAME="{各自のprofile_nameを入れる}"
PROFILE_NAME="wanrun"

# Create S3 bucket for terraform state
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $REGION \
    --create-bucket-configuration LocationConstraint=$REGION \
    --profile $PROFILE_NAME

aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled \
    --profile $PROFILE_NAME

aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --profile $PROFILE_NAME \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

aws s3api put-bucket-policy \
    --bucket $BUCKET_NAME \
    --profile $PROFILE_NAME \
    --policy '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Deny",
                "Action": "s3:*",
                "Resource": "arn:aws:s3:::'"$BUCKET_NAME"'/*",
                "Principal": "*",
                "Condition": {
                    "Bool": {
                        "aws:SecureTransport": "false"
                    }
                }
            }
        ]
    }'

echo "S3 bucket $BUCKET_NAME created and configured with security settings."
# TODO: 共同開発が始まったら作成
# Create DynamoDB table for terraform state lock
# aws dynamodb create-table \
#     --table-name $DYNAMODB_TABLE \
#     --attribute-definitions AttributeName=LockID,AttributeType=S \
#     --key-schema AttributeName=LockID,KeyType=HASH \
#     --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
#     --region $REGION
