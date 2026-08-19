provider "aws" {
  region = "eu-west-2"
}

resource "aws_ecr_repository" "task_listing_ecr" {
  name                 = "gh-jg-aw-task-listing-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

