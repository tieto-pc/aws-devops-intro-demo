locals {
  my_name = "${var.prefix}-${var.env}-codebuild"
  my_env  = "${var.prefix}-${var.env}"
}

# Adopted from Terraform template: https://www.terraform.io/docs/providers/aws/r/codebuild_project.html

resource "aws_s3_bucket" "codebuild_s3_cache_bucket" {
  bucket = "${local.my_name}-cache-bucket"
  acl    = "private"

  tags {
    Name        = "${local.my_name}-cache-bucket"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
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
    Name        = "${local.my_name}-iam-role"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}


# Removed ec2 rights, let's see if they are actually needed for the service.
resource "aws_iam_role_policy" "codebuild_iam_role_policy" {
  role = "${aws_iam_role.codebuild_iam_role.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.codebuild_s3_cache_bucket.arn}",
        "${aws_s3_bucket.codebuild_s3_cache_bucket.arn}/*"
      ]
    }
  ]
}
EOF
}


# Not using any vpc as in the original example.
resource "aws_codebuild_project" "codebuild_project" {
  name          = "${local.my_name}-project"
  description   = "CodeBuild demo project"
  build_timeout = "60"
  service_role  = "${aws_iam_role.codebuild_iam_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type     = "S3"
    location = "${aws_s3_bucket.codebuild_s3_cache_bucket.bucket}"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type = "CODEPIPELINE"
  }

  tags {
    Name        = "${local.my_name}-codebuild-project"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}