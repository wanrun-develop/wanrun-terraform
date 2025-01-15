module "db_ec2" {
  source = "../../../modules/db/ec2"

  service_name = var.service_name
  env          = var.env

  # network
  subnet_id          = element(data.aws_subnet_ids.private.ids, 0)
  security_group_ids = [data.aws_security_group.postgres_on_ec2_sg.id]

  # ec2
  ec2_instance_type = "t4g.micro"

  # ebs
  ebs_volume_size = 8
  ebs_iops        = 3000
  ebs_throughput  = 125
}
