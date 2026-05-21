resource "aws_ecr_repository" "crm_api" {
  name                 = "${var.project_name}-crm-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-crm-api-ecr"
    }
  )
}

resource "aws_ecr_lifecycle_policy" "crm_api" {
  repository = aws_ecr_repository.crm_api.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus     = "any"
        countType     = "imageCountMoreThan"
        countNumber   = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}

output "ecr_repository_url" {
  description = "URL du repository ECR"
  value       = aws_ecr_repository.crm_api.repository_url
}
