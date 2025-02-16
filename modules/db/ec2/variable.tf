variable "service_name" {
  type    = string
  default = ""
}

variable "env" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type    = string
  default = ""
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "ec2_instance_type" {
  type    = string
  default = "t4g.micro"
}

variable "ebs_volume_size" {
  type    = number
  default = 0
}

variable "ebs_iops" {
  type    = number
  default = 3000
}

variable "ebs_throughput" {
  type    = number
  default = 125
}
