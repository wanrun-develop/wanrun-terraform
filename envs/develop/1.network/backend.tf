terraform {
  backend "s3" {
    encrypt = true
    bucket  = "wanrun-develop-terraform-tfstate"
    region  = "ap-northeast-1"
    key     = "network/terraform.tfstate"
    # TODO: 共同開発が始まったら作成
    # dynamodb_table = "terraform-state-lock"
  }
}
