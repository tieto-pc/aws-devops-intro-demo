

output codebuild_build_and_test_project_arn {
  value = "${aws_codebuild_project.codebuild_build_and_test_project.arn}"
}

output codebuild_build_and_test_project_name {
  value = "${aws_codebuild_project.codebuild_build_and_test_project.name}"
}
