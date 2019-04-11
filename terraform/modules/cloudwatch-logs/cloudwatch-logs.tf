locals {
  my_name       = "${var.prefix}-${var.env}-codebuild"
  my_deployment = "${var.prefix}-${var.env}"
}

resource "aws_cloudwatch_log_group" "cloudwatch_codebuild_log_group" {
  name = "${local.my_name}-codebuild-logs"

  tags {
    Name        = "${local.my_name}-codebuild-logs"
    Deployment  = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}
