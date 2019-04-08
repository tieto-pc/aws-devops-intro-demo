locals {
  my_name = "${var.prefix}-${var.env}-codebuild"
  my_env  = "${var.prefix}-${var.env}"
}

# Adopted from Terraform template: https://www.terraform.io/docs/providers/aws/r/codebuild_project.html


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
        "${var.s3_cache_bucket_arn}",
        "${var.s3_cache_bucket_arn}/*",
        "${var.s3_log_bucket_arn}",
        "${var.s3_log_bucket_arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:GitPull"
      ],
      "Resource": [
        "arn:aws:codecommit:eu-west-1:943670737262:devopsintro-dev-codecommit-repo"
      ]
    }
  ]
}
EOF
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


# Not using any vpc as in the original example.
# Mostly using values from the manually created CodeBuild that I used to validate a working configuration.
# See README.md.
# Builds and tests the Java project.
resource "aws_codebuild_project" "codebuild_build_and_test_project" {
  name          = "${local.my_name}-project"
  description   = "CodeBuild demo project"
  build_timeout = "5"
  service_role  = "${aws_iam_role.codebuild_iam_role.arn}"
  badge_enabled = "false"

  source {
    type            = "CODECOMMIT"
    location        = "${var.codecommit_repo_http_url}"
    git_clone_depth = "1"
    buildspec       = "buildspec.yml"
    insecure_ssl    = "false"
  }

  # We let CodePipeline to push the artifact to S3.
  artifacts {
    type                = "NO_ARTIFACTS"
  }

  environment {
    type                        = "LINUX_CONTAINER"
    image                       = "aws/codebuild/standard:1.0-1.8.0"
    compute_type                = "BUILD_GENERAL1_SMALL"
    privileged_mode             = "false"
  }

  cache {
    type     = "S3"
    location = "${var.s3_cache_bucket}"
  }

  # Terraform does not expose logsConfig part, see: https://github.com/terraform-providers/terraform-provider-aws/issues/6312

  tags {
    Name        = "${local.my_name}-codebuild-project"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}


# TODO: resource "aws_codebuild_project" "codebuild_bake_docker_image_project" {
