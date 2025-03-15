#######################################################################
# ecr initialize
#######################################################################
resource "aws_ecr_repository" "initialize" {
  name = "${var.service_name}-global-lambda-initialize"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

data "aws_ecr_lifecycle_policy_document" "initialize" {
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
    description = "Only keep ${var.lambda_initialize_retention_image_count} images for application repositories."

    selection {
      tag_status   = "any"
      count_type   = "imageCountMoreThan"
      count_number = var.lambda_initialize_retention_image_count
    }
    action {
      type = "expire"
    }
  }
}

resource "aws_ecr_lifecycle_policy" "initialize" {
  repository = aws_ecr_repository.initialize.name
  policy     = data.aws_ecr_lifecycle_policy_document.initialize.json
}
