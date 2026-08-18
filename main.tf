provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket-gh-jg-aw"

  tags = {
    Name = "My test bucket"
  }
}