terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">=0.14.9"
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

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.ph.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.ph.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.example]
}

data "aws_iam_policy_document" "allow_public_read" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
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

resource "aws_s3_bucket_policy" "ph-policy" {
  bucket = aws_s3_bucket.ph.id
  policy = data.aws_iam_policy_document.allow_public_read.json
  depends_on = [aws_s3_bucket_public_access_block.example]
}

resource "aws_s3_bucket" "ph_2" {
     bucket = var.bucket_name_2
}

resource "aws_s3_bucket_website_configuration" "ph-config-2" {
  bucket = aws_s3_bucket.ph_2.bucket
  
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "example_2" {
  bucket = aws_s3_bucket.ph_2.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.ph_2.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [aws_s3_bucket_public_access_block.example_2]
}

data "aws_iam_policy_document" "allow_public_read_2" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      aws_s3_bucket.ph_2.arn,
      "${aws_s3_bucket.ph_2.arn}/*",
    ]
  }
}