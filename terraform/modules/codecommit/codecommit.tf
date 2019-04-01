locals {
  my_name = "${var.prefix}-${var.env}-codecommit"
  my_env = "${var.prefix}-${var.env}"
}


resource "aws_codecommit_repository" "codecommit_repo" {
  repository_name = "${local.my_name}-repo"
  description     = "AWS DevOps demonstration repository"
}

