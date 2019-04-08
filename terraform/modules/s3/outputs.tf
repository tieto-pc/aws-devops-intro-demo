

output "s3_cache_bucket" {
  value = "${aws_s3_bucket.codebuild_s3_cache_bucket.bucket}"
}

output "s3_cache_bucket_arn" {
  value = "${aws_s3_bucket.codebuild_s3_cache_bucket.arn}"
}

output "s3_artifact_bucket" {
  value = "${aws_s3_bucket.codebuild_s3_artifact_bucket.bucket}"
}

output "s3_artifact_bucket_arn" {
  value = "${aws_s3_bucket.codebuild_s3_artifact_bucket.arn}"
}

output "s3_log_bucket" {
  value = "${aws_s3_bucket.codebuild_s3_log_bucket.bucket}"
}

output "s3_log_bucket_arn" {
  value = "${aws_s3_bucket.codebuild_s3_log_bucket.arn}"
}

