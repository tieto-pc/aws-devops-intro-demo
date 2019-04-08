

output "codecommit_repo_http_url" {
  value = "${aws_codecommit_repository.codecommit_repo.clone_url_http}"
}

output "codecommit_repo_name" {
  value = "${aws_codecommit_repository.codecommit_repo.repository_name}"
}

output "codecommit_repo_arn" {
  value = "${aws_codecommit_repository.codecommit_repo.arn}"
}
