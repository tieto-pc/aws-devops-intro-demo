locals {
  my_name = "${var.prefix}-${var.env}-codepipeline"
  my_deployment = "${var.prefix}-${var.env}"
}


# Adopted from Terraform template: https://www.terraform.io/docs/providers/aws/r/codepipeline.html

resource "aws_iam_role_policy" "codepipeline_iam_role_policy" {
  name = "${local.my_name}-iam-role-policy"
  role = "${aws_iam_role.codepipeline_iam_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${var.s3_cache_bucket_arn}",
        "${var.s3_cache_bucket_arn}/*",
        "${var.s3_log_bucket_arn}",
        "${var.s3_log_bucket_arn}/*",
        "${var.s3_artifact_bucket_arn}",
        "${var.s3_artifact_bucket_arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": [
        "${var.codebuild_build_and_test_project_arn}",
        "${var.codebuild_build_docker_image_project_arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:GitPull",
        "codecommit:GetUploadStatus",
        "codecommit:CancelUploadArchive",
        "codecommit:GetBranch",
        "codecommit:GetCommit",
        "codecommit:GetUploadArchiveStatus",
        "codecommit:UploadArchive"
      ],
      "Resource": [
        "${var.codecommit_repo_arn}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "codepipeline_iam_role" {
  name = "${local.my_name}-iam-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags {
    Name        = "${local.my_name}-iam-role"
    Deployment  = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }

}


resource "aws_codepipeline" "codepipeline_project" {
  name = "${local.my_name}-project"
  role_arn = "${aws_iam_role.codepipeline_iam_role.arn}"


  artifact_store {
    type = "S3"
    location = "${var.s3_artifact_bucket}"
  }

  ########## Source stage #########
  stage {
    name = "${local.my_name}-source-stage"

    action {
      name = "${local.my_name}-source-stage"
      category = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"
      output_artifacts = [
        "source-artifact"]
      configuration = {
        RepositoryName = "${var.codecommit_repo_name}"
        BranchName = "master"
        PollForSourceChanges = "false"
      }
    }
  }

  ########## Build and test stage #########
  stage {
    name = "${local.my_name}-build-and-test-stage"

    action {
      name = "${local.my_name}-build-and-test-action-1"
      run_order = 1
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      input_artifacts = [
        "source-artifact"]
      output_artifacts = [
        "app-jar-artifact"]
      version = "1"

      configuration = {
        ProjectName = "${var.codebuild_build_and_test_project_name}"
      }
    }

    action {
      name = "${local.my_name}-upload-jar-action-2"
      run_order = 2
      category = "Deploy"
      owner = "AWS"
      provider = "S3"
      input_artifacts = [
        "app-jar-artifact"]
      version = "1"

      configuration = {
        BucketName = "${var.s3_artifact_bucket}"
        Extract = "true"
        ObjectKey = "app-jar"
      }
    }
  }

  ########## Build Docker image stage #########
  stage {
    name = "${local.my_name}-build-docker-image-stage"

    action {
      name = "${local.my_name}-build-docker-image-stage"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      input_artifacts = [
        "source-artifact"]
      version = "1"

      configuration = {
        ProjectName = "${var.codebuild_build_docker_image_project_name}"
      }
    }

  }

}