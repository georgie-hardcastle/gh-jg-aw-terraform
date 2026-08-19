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

resource "aws_s3_bucket" "task_listing_s3_bucket" {
  bucket = "gh-jg-aw-task-listing-deployment-bucket"
}

resource "aws_s3_bucket_versioning" "task_listing_s3_bucket_versioning" {
  bucket = aws_s3_bucket.task_listing_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}