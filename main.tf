terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">=0.14.9"
/*
   backend "s3" {
       bucket = "ph-dev-terraform"
       key = "terraform.tfstate"
       region = "us-east-1"
   }
*/
}

provider "aws" {
  region  = "us-east-1"
}

resource "aws_s3_bucket" "ph" {
     bucket = "pth-website-demo"
}

resource "aws_s3_bucket_website_configuration" "ph-config" {
  bucket = aws_s3_bucket.ph.bucket
  
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.ph.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.example]
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.ph.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "ph-policy" {
  bucket = aws_s3_bucket.ph.id
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "PublicReadGetObject",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::pth-website-demo/*"
      }
    ]
  }

  EOF

  depends_on = [aws_s3_bucket_public_access_block.example]
}