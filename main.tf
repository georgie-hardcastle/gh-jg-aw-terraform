provider "aws" {
  region = "eu-west-2"
}

# Reference Default VPC
data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnets" "default_subnet" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

# Create ECR
resource "aws_ecr_repository" "task_listing_ecr" {
  name                 = "gh-jg-aw-task-listing-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Create S3 Bucket
resource "aws_s3_bucket" "task_listing_s3_bucket" {
  bucket = "gh-jg-aw-task-listing-deployment-bucket"
}

# Enable Versioning on S3 Bucket
resource "aws_s3_bucket_versioning" "task_listing_s3_bucket_versioning" {
  bucket = aws_s3_bucket.task_listing_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#Create Elastic Beanstalk App
resource "aws_elastic_beanstalk_application" "task_listing_eba" {
  name        = "gh-jg-aw-task-listing-app"
  description = "Task listing app"
}

# Creating IAM Instance Profile
resource "aws_iam_instance_profile" "task_listing_app_ec2_instance_profile" {
  name = "gh-jg-aw-task-listing-app-ec2-instance-profile"
  role = aws_iam_role.task_listing_app_ec2_role.name
}

resource "aws_iam_role" "task_listing_app_ec2_role" {
  name = "gh-jg-aw-task-listing-app-ec2-instance-role"

  // Allows the EC2 instances in our EB environment to assume (take on) this 
  // role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
}

# Create Web Server Environment 
resource "aws_elastic_beanstalk_environment" "task_listing_eba_environment" {
  name        = "gh-jg-aw-task-listing-app-environment"
  application = aws_elastic_beanstalk_application.task_listing_eba.name

  # This page lists the supported platforms
  # we can use for this argument:
  # https://docs.aws.amazon.com/elasticbeanstalk/latest/platforms/platforms-supported.html#platforms-supported.docker
  solution_stack_name = "64bit Amazon Linux 2023 v4.0.1 running Docker"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.task_listing_app_ec2_instance_profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "johnny-devops-pair"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = data.aws_vpc.default_vpc.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", data.aws_subnets.default_subnet.ids)
  }
}