variable "service_name" {
  type    = string
  default = ""
}

variable "env" {
  type    = string
  default = ""
}

variable "web_front_domain" {
  type    = string
  default = ""
}

variable "front_web_waf_acl_id" {
  type    = string
  default = ""
}

variable "cloudfront_acm_arn" {
  type    = string
  default = ""
}
