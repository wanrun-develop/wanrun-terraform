locals {
  wanrun = {
    service_name                      = "wanrun"
    priority                          = 1
    health_check_path                 = "/wanrun/health"
    path_pattern                      = ["/wanrun/*"]
    health_check_grace_period_seconds = 120
    all_cpu                           = 256
    all_mem                           = 1024
    image_tag                         = "latest"
    container_cpu                     = 256
    container_mem                     = 1024
    container_environment             = []
    container_secrets                 = []
  }
}

###########################################
# ecr
###########################################
resource "aws_ecr_repository" "wanrun" {
  name = var.ecr_namespace

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

data "aws_ecr_lifecycle_policy_document" "wanrun" {
  rule {
    priority    = 1
    description = "Only keep untagged images for 1 day."

    selection {
      tag_status   = "untagged"
      count_type   = "sinceImagePushed"
      count_number = 1
      count_unit   = "days"
    }
    action {
      type = "expire"
    }
  }
  rule {
    priority    = 2
    description = "Only keep ${var.retention_image_count} images for application repositories."

    selection {
      tag_status   = "any"
      count_type   = "imageCountMoreThan"
      count_number = var.retention_image_count
    }
    action {
      type = "expire"
    }
  }
}

resource "aws_ecr_lifecycle_policy" "wanrun" {
  repository = aws_ecr_repository.wanrun.name
  policy     = data.aws_ecr_lifecycle_policy_document.wanrun.json
}

###########################################
# target group
###########################################
resource "aws_lb_target_group" "wanrun" {
  name                 = "${var.service_name}-${var.env}-${local.wanrun.service_name}"
  port                 = 8080
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  deregistration_delay = 300

  health_check {
    enabled             = true
    path                = local.wanrun.health_check_path
    protocol            = "HTTP"
    matcher             = 200
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    interval            = 30
  }
}

###########################################
# alb listener rule
###########################################
resource "aws_lb_listener_rule" "wanrun" {
  listener_arn = aws_lb_listener.internal_gateway.arn
  priority     = local.wanrun.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wanrun.arn
    order            = 1
  }

  condition {
    path_pattern {
      values = local.wanrun.path_pattern
    }
  }
}

###########################################
# ecs service
###########################################
resource "aws_ecs_service" "wanrun" {
  name             = "${var.service_name}-${var.env}-${local.wanrun.service_name}"
  cluster          = aws_ecs_cluster.main.id
  task_definition  = aws_ecs_task_definition.wanrun.arn
  desired_count    = 0
  platform_version = "1.4.0"
  load_balancer {
    target_group_arn = aws_lb_target_group.wanrun.arn
    container_name   = local.wanrun.service_name
    container_port   = 8080
  }

  health_check_grace_period_seconds = local.wanrun.health_check_grace_period_seconds
  enable_execute_command            = var.env == "develop" ? true : false

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = var.fargate_weight_capacity_provider_strategy
    base              = var.fargate_base_capacity_provider_strategy
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = var.fargate_spot_weight_capacity_provider_strategy
    base              = var.fargate_spot_base_capacity_provider_strategy
  }

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    assign_public_ip = false
    subnets          = var.private_subnet_ids
    security_groups  = var.fargate_sg_ids
  }

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition,
      # load_balancer,
      # capacity_provider_strategy
    ]
  }

  depends_on = [
    aws_lb_target_group.wanrun,
    aws_lb_listener_rule.wanrun,
  ]
}

###########################################
# taskdefinition
###########################################
resource "aws_ecs_task_definition" "wanrun" {
  family                   = "${var.service_name}-${var.env}-${local.wanrun.service_name}"
  cpu                      = local.wanrun.all_cpu
  memory                   = local.wanrun.all_mem
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  execution_role_arn = aws_iam_role.ecs_task_execution_common.arn
  task_role_arn      = aws_iam_role.wanrun_ecs_task_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = var.cpu_architecture
  }

  container_definitions = jsonencode(
    [
      {
        "name" : local.wanrun.service_name,
        "essential" : true,
        "image" : "${aws_ecr_repository.wanrun.repository_url}:${local.wanrun.image_tag}",
        "cpu" : local.wanrun.container_cpu,
        "memory" : local.wanrun.container_mem,
        "logConfiguration" : {
          "logDriver" : "awslogs",
          "options" : {
            "awslogs-create-group" : "true",
            "awslogs-group" : "/ecs/${var.service_name}-${var.env}/${local.wanrun.service_name}",
            "awslogs-region" : "ap-northeast-1",
            "awslogs-stream-prefix" : "${var.service_name}-${var.env}/${local.wanrun.service_name}"
          }
        },
        "portMappings" : [
          {
            "hostPort" : 8080,
            "protocol" : "tcp",
            "containerPort" : 8080
          }
        ],
        "environment" : [
          {
            "name" : "JWT_EXP_TIME",
            "value" : "3"
          },
          {
            "name" : "REFRESH_JWT_EXP_TIME",
            "value" : "72"
          },
          {
            "name" : "AWS_S3_BUCKET_NAME",
            "value" : "__SERVICE_NAME__-__ENV__-cms"
          }
        ]
        "secrets" : [
          {
            "name" : "SECRET_KEY"
            "valueFrom" : "/__UPPERCASE_SERVICE_NAME__/__UPPERCASE_ENV__/WANRUN/SECRET_KEY"
          }
        ]
      }
    ]
  )
}
