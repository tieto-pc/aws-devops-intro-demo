

output "codecommit_repo_http_url" {
  value = "${aws_codecommit_repository.codecommit_repo.clone_url_http}"
}

