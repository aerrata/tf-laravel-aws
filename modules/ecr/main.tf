resource "aws_ecr_repository" "image_repository" {
  name                 = "komet/next-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
