locals {
  my_name = "${var.prefix}-${var.env}-codebuild"
  my_env  = "${var.prefix}-${var.env}"
}

resource "aws_cloudwatch_log_group" "cloudwatch_codebuild_log_group" {
  name = "${local.my_name}-codebuild-logs"

  tags {
    Name        = "${local.my_name}-codebuild-logs"
    Environment = "${local.my_env}"
    Prefix      = "${var.prefix}"
    Env         = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }
}
