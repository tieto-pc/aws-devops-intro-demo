

output "codecommit_repo_name" {
  value = "${aws_codecommit_repository.codecommit_repo.repository_name}"
}

