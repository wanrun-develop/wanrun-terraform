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

variable "alb_wanrun_sgs" {
  type    = string
  default = ""
}

variable "public_subnets" {
  type    = list(string)
  default = []
}

variable "alb_wanrun_idle_time" {
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

variable "certificate_arn" {
  type    = string
  default = ""
}

variable "is_container_insights" {
  type    = bool
  default = false
}

variable "fargate_base_capacity_provider_strategy" {
  type    = number
  default = 0
}

variable "fargate_weight_capacity_provider_strategy" {
  type        = number
  default     = 0
  description = "本番は1以上にする"
}

variable "fargate_spot_base_capacity_provider_strategy" {
  type    = number
  default = 0
}

variable "fargate_spot_weight_capacity_provider_strategy" {
  type        = number
  default     = 0
  description = "本番は0にする"
}
