variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnets_cidr" {
  type = map(string)
  default = {
    public_subnet_1a = "10.0.0.0/24"
    public_subnet_1c = "10.0.2.0/24"
    public_subnet_1d = "10.0.4.0/24"

    private_subnet_1a = "10.0.1.0/24"
    private_subnet_1c = "10.0.3.0/24"
    private_subnet_1d = "10.0.5.0/24"
  }
}
