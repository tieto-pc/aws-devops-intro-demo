locals {
  my_name = "${var.prefix}-${var.env}-codebuild"
  my_env = "${var.prefix}-${var.env}"
}

resource "aws_s3_bucket" "codebuild_s3_cache_bucket" {
  bucket = "${local.my_name}-cache-bucket"
  acl    = "private"

  tags {
    Name = "${local.my_name}-cache-bucket"
    Environment = "${local.my_env}"
    Prefix = "${var.prefix}"
    Env = "${var.env}"
    Region = "${var.region}"
    Terraform = "true"
  }
}


resource "aws_iam_role" "codebuild_iam_role" {
  name = "${local.my_name}-iam-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags {
    Name = "${local.my_name}-iam-role"
    Environment = "${local.my_env}"
    Prefix = "${var.prefix}"
    Env = "${var.env}"
    Region = "${var.region}"
    Terraform = "true"
  }
}

