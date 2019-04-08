

output "cloudwatch_codebuild_log_group_name" {
  value = "${aws_cloudwatch_log_group.cloudwatch_codebuild_log_group.name}"
}

