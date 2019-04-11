locals {
  my_name = "${var.prefix}-${var.env}-codebuild"
  my_deployment = "${var.prefix}-${var.env}"
}

# Adopted from Terraform template: https://www.terraform.io/docs/providers/aws/r/codebuild_project.html


# Removed ec2 rights, let's see if they are actually needed for the service.
resource "aws_iam_role_policy" "codebuild_iam_role_policy" {
  name = "${local.my_name}-iam-role-policy"
  role = "${aws_iam_role.codebuild_iam_role.id}"

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
        "${var.s3_log_bucket_arn}/*",
        "${var.s3_artifact_bucket_arn}",
        "${var.s3_artifact_bucket_arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "ecr:GetAuthorizationToken"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": "arn:aws:ecr:${var.region}:${var.aws_account_id}:repository/${var.ecr_registry_name}",
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:GitPull"
      ],
      "Resource": [
        "${var.codecommit_repo_arn}"
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
    Name = "${local.my_name}-iam-role"
    Deployment = "${local.my_deployment}"
    Prefix = "${var.prefix}"
    Environment = "${var.env}"
    Region = "${var.region}"
    Terraform = "true"
  }
}


# Not using any vpc as in the original example.
# Mostly using values from the manually created CodeBuild that I used to validate a working configuration.
# See README.md.
# Builds and tests the Java project.
resource "aws_codebuild_project" "codebuild_build_and_test_project" {
  name = "${local.my_name}-build-and-test-project"
  description = "CodeBuild demo project - builds and tests a Java project"
  build_timeout = "5"
  service_role = "${aws_iam_role.codebuild_iam_role.arn}"
  badge_enabled = "false"

  source {
    type = "CODECOMMIT"
    location = "${var.codecommit_repo_http_url}"
    git_clone_depth = "1"
    buildspec = "codebuild/buildspec_build_and_test.yml"
    insecure_ssl = "false"
  }

  # We let CodePipeline to push the artifact to S3.
  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type = "LINUX_CONTAINER"
    image = "aws/codebuild/standard:1.0-1.8.0"
    compute_type = "BUILD_GENERAL1_SMALL"
    privileged_mode = "false"
  }

// TODO: See next commented cache.
//  cache {
//    type = "S3"
//    location = "${var.s3_cache_bucket}"
//  }

  # Terraform does not expose logsConfig part, see: https://github.com/terraform-providers/terraform-provider-aws/issues/6312

  tags {
    Name = "${local.my_name}-build-and-test-project"
    Deployment = "${local.my_deployment}"
    Prefix = "${var.prefix}"
    Environment = "${var.env}"
    Region = "${var.region}"
    Terraform = "true"
  }
}


# Builds the docker image.
resource "aws_codebuild_project" "codebuild_build_docker_image_project" {
  name = "${local.my_name}-build-docker-image-project"
  description = "CodeBuild demo project- builds the docker image"
  build_timeout = "5"
  service_role = "${aws_iam_role.codebuild_iam_role.arn}"
  badge_enabled = "false"

  source {
    type = "CODECOMMIT"
    location = "${var.codecommit_repo_http_url}"
    git_clone_depth = "1"
    buildspec = "codebuild/buildspec_build_docker_image.yml"
    insecure_ssl = "false"
  }

  # We let CodePipeline to push the artifact to S3.
  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    type = "LINUX_CONTAINER"
    image = "aws/codebuild/standard:1.0-1.8.0"
    compute_type = "BUILD_GENERAL1_SMALL"
    privileged_mode = "true"

    environment_variable {
      name = "MY_IMAGE_NAME"
      value = "${var.docker_app_image_name}"
    }
    environment_variable {
      name = "MY_AWS_REGION"
      value = "${var.region}"
    }
    environment_variable {
      name = "MY_ECR_REPO"
      value = "${var.ecr_registry_name}"
    }
    environment_variable {
      name = "MY_AWS_ACCOUNT_ID"
      value = "${var.aws_account_id}"
    }
    environment_variable {
      name = "MY_S3_APP_BUCKET"
      value = "${var.s3_artifact_bucket}"
    }
  }

// TODO: For some reason couldn't make the cache work (access right), even though
// I thought the role has the right for the bucket.
//  cache {
//    type = "S3"
//    location = "${var.s3_cache_bucket}"
//  }

  # Terraform does not expose logsConfig part, see: https://github.com/terraform-providers/terraform-provider-aws/issues/6312

  tags {
    Name = "${local.my_name}-build-docker-image-project"
    Deployment = "${local.my_deployment}"
    Prefix = "${var.prefix}"
    Environment = "${var.env}"
    Region = "${var.region}"
    Terraform = "true"
  }
}

