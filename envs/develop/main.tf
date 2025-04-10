locals {
  ssm_parameter_store_prefix = "/${upper(var.service_name)}/${upper(var.env)}"
}
variable "service_name" {
  type    = string
  default = "wr"
}

variable "env" {
  type    = string
  default = "develop"
}

variable "fargate_base_capacity_provider_strategy" {
  type        = number
  default     = 0
  description = "本番は1以上にする"
}

variable "fargate_weight_capacity_provider_strategy" {
  type        = number
  default     = 1
  description = "Fargate(オンデマンド)とFargate spotでの起動するタスクの割合。baseを超えてから追加される比率"
}

variable "fargate_spot_base_capacity_provider_strategy" {
  type        = number
  default     = 1
  description = "本番は0にする"
}

variable "fargate_spot_weight_capacity_provider_strategy" {
  type        = number
  default     = 3
  description = "Fargate(オンデマンド)とFargate spotでの起動するタスクの割合。baseを超えてから追加される比率"
}

terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.86"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      ManagedBy = "terraform"
      Envs      = "develop"
      UseCase   = "wanrun"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "virginia"

  default_tags {
    tags = {
      ManagedBy = "terraform"
      Envs      = "develop"
      UseCase   = "wanrun"
    }
  }
}
