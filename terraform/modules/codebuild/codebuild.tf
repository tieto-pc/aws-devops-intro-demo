locals {
  my_name = "${var.prefix}-${var.env}-codebuild"
  my_env = "${var.prefix}-${var.env}"
}

# Adopted from Terraform template: https://www.terraform.io/docs/providers/aws/r/codebuild_project.html

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


# See: https://docs.aws.amazon.com/codebuild/latest/userguide/auth-and-access-control-iam-identity-based-access-control.html
resource "aws_iam_role_policy" "example" {
  role = "${aws_iam_role.codebuild_iam_role.name}"

  policy = <<POLICY
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
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
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
POLICY
}

