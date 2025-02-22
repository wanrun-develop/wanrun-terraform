####################################################################
# ec2 postgres
####################################################################
resource "aws_instance" "main" {
  ami                         = data.aws_ssm_parameter.amazonlinux_2023.value
  instance_type               = var.ec2_instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = false
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = aws_iam_instance_profile.postgres_main_db.name

  tags = {
    Name = "${var.service_name}-${var.env}-main-db"
  }

  user_data = <<EOF
  #!/bin/bash
  dnf update -y \
      && dnf install -y \
              cronie \
              git \
  && rm -rf /var/cache/dnf/
  ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
  EOF

  // EBS
  ebs_optimized = true
  root_block_device {
    volume_size = var.ebs_volume_size
    volume_type = "gp3"
    iops        = var.ebs_iops
    throughput  = var.ebs_throughput

    delete_on_termination = false
    encrypted             = "true"
    tags = {
      Name = "${var.service_name}-${var.env}-main-db"
    }
  }
}
