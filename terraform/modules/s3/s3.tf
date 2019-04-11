locals {
  my_name = "${var.prefix}-${var.env}-codebuild"
  my_deployment  = "${var.prefix}-${var.env}"
}


resource "aws_s3_bucket" "codebuild_s3_cache_bucket" {
  bucket = "${local.my_name}-cache-bucket"
  acl    = "private"

  tags {
    Name        = "${local.my_name}-cache-bucket"
    Deployment = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}

resource "aws_s3_bucket" "codebuild_s3_artifact_bucket" {
  bucket = "${local.my_name}-artifact-bucket"
  acl    = "private"

  tags {
    Name        = "${local.my_name}-artifact-bucket"
    Deployment = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}


resource "aws_s3_bucket" "codebuild_s3_log_bucket" {
  bucket = "${local.my_name}-log-bucket"
  acl    = "private"

  tags {
    Name        = "${local.my_name}-log-bucket"
    Deployment = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}


