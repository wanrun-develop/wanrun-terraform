###########################################
# s3とDynamoDB作成用のスクリプト
# これらのリソースは、terraformの管理対象外のため手動作成する
###########################################

#!/bin/bash

ORG_NAME="wanrun"
REGION="ap-northeast-1"
ENV="develop"
BUCKET_NAME="$ORG_NAME-$ENV-terraform-tfstate"
DYNAMODB_TABLE="$ORG_NAME-terraform-state-lock"

# Create S3 bucket for terraform state
aws s3api create-bucket \
    --bucket $BUCKET_NAME \
    --region $REGION \
    --create-bucket-configuration LocationConstraint=$REGION

aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# TODO: 共同開発が始まったら作成
# Create DynamoDB table for terraform state lock
# aws dynamodb create-table \
#     --table-name $DYNAMODB_TABLE \
#     --attribute-definitions AttributeName=LockID,AttributeType=S \
#     --key-schema AttributeName=LockID,KeyType=HASH \
#     --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
#     --region $REGION
