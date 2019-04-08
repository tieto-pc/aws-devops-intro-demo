locals {
  my_name = "${var.prefix}-${var.env}-codebuild"
  my_env  = "${var.prefix}-${var.env}"
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
