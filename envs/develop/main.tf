variable "service_name" {
  type    = string
  default = "wanrun"
}

variable "env" {
  type    = string
  default = "develop"
}

terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.65"
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
