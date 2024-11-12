###########################################
# ecs cluster
###########################################
resource "aws_ecs_cluster" "main" {
  name = "${var.service_name}-${var.env}-cluster"

  setting {
    name  = "containerInsights"
    value = var.is_container_insights ? "enabled" : "disabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = var.fargate_base_capacity_provider_strategy
    weight            = var.fargate_weight_capacity_provider_strategy
    capacity_provider = "FARGATE"
  }

  default_capacity_provider_strategy {
    base              = var.fargate_spot_base_capacity_provider_strategy
    weight            = var.fargate_spot_weight_capacity_provider_strategy
    capacity_provider = "FARGATE_SPOT"
  }
}
