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
     bucket = var.bucket_name
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

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "ph-policy" {
  bucket = aws_s3_bucket.ph.id
  policy = data.aws_iam_policy_document.allow_public_read.json
  depends_on = [aws_s3_bucket_public_access_block.example]
}

data "aws_iam_policy_document" "allow_public_read" {
  statement {
    principals {
      type        = "AWS"
      identifiers = "*"
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.ph.arn,
      "${aws_s3_bucket.ph.arn}/*",
    ]
  }
}