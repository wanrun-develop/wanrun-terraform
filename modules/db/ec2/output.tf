####################################################################
# wanrun ec2
####################################################################
output "wanrun_postgres_private_ip" {
  value = aws_instance.main.private_ip
}
