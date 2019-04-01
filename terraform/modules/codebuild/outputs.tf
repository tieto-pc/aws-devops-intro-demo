

output "codebuild_s3_cache_bucket_arn" {
  value = "${aws_s3_bucket.codebuild_s3_cache_bucket.arn}"
}

