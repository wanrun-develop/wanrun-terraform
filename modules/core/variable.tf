variable "service_name" {
  type    = string
  default = ""
}

variable "env" {
  type    = string
  default = ""
}

variable "main_domain" {
  type    = string
  default = ""
}

variable "main_waf_acl_id" {
  type    = string
  default = ""
}

variable "cloudfront_acm_arn" {
  type    = string
  default = ""
}

variable "whitelist_locations" {
  type    = list(string)
  default = ["JP"]
}

variable "internal_gateway_security_groups" {
  type    = list(string)
  default = [""]
}

variable "public_subnets" {
  type    = list(string)
  default = []
}

variable "alb_internal_gateway_idle_time" {
  type    = number
  default = 60
}

variable "alb_wanrun_access_log_bucket_id" {
  type    = string
  default = ""
}

variable "alb_wanrun_access_log_prefix" {
  type    = string
  default = ""
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-2016-08"
}

variable "is_container_insights" {
  type    = bool
  default = false
}

variable "fargate_base_capacity_provider_strategy" {
  type        = number
  default     = 0
  description = "本番は1以上にする"
}

variable "fargate_weight_capacity_provider_strategy" {
  type        = number
  default     = 0
  description = "Fargate(オンデマンド)とFargate spotでの起動するタスクの割合。baseを超えてから追加される比率"
}

variable "fargate_spot_base_capacity_provider_strategy" {
  type        = number
  default     = 0
  description = "本番は0にする"
}

variable "fargate_spot_weight_capacity_provider_strategy" {
  type        = number
  default     = 0
  description = "Fargate(オンデマンド)とFargate spotでの起動するタスクの割合。baseを超えてから追加される比率"
}

variable "ecr_namespace" {
  type    = string
  default = ""
}

variable "retention_image_count" {
  type    = number
  default = 3
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "kms_key_arn" {
  type    = string
  default = ""
}

variable "private_subnet_ids" {
  type    = list(string)
  default = []
}

variable "fargate_sg_ids" {
  type    = list(string)
  default = []
}

variable "cpu_architecture" {
  type    = string
  default = "ARM64"
}

variable "retention_period" {
  type    = number
  default = 365
}

variable "access_control_allow_origins" {
  type    = list(string)
  default = [""]
}
