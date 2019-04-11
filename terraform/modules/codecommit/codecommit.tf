locals {
  my_name        = "${var.prefix}-${var.env}-codecommit"
  my_deployment  = "${var.prefix}-${var.env}"
}


resource "aws_codecommit_repository" "codecommit_repo" {
  repository_name = "${local.my_name}-repo"
  description     = "AWS DevOps demonstration repository"
}


# See: https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-trigger-source-repo-changes-console.html

resource "aws_cloudwatch_event_rule" "codecommit_cloudwatch_event_rule" {
  name = "${local.my_name}-codecommit-cloudwatch-event-rule"

  event_pattern = <<EOF
{
  "source": [
    "aws.codecommit"
  ],
  "detail-type": [
    "CodeCommit Repository State Change"
  ],
  "resources": [
    "${aws_codecommit_repository.codecommit_repo.arn}"
  ],
  "detail": {
    "event": [
      "referenceCreated",
      "referenceUpdated"
    ],
    "referenceType": [
      "branch"
    ],
    "referenceName": [
      "master"
    ]
  }
}
EOF
}


resource "aws_iam_role" "codecommit_cloudwatch_iam_role" {
  name = "${local.my_name}-codecommit-cloudwatch-iam-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags {
    Name        = "${local.my_name}-codecommit-cloudwatch-iam-role"
    Deployment  = "${local.my_deployment}"
    Prefix      = "${var.prefix}"
    Environment = "${var.env}"
    Region      = "${var.region}"
    Terraform   = "true"
  }

}

resource "aws_iam_role_policy" "codecommit_cloudwatch_iam_policy" {
  name = "${local.my_name}-codecommit-cloudwatch-iam-role-policy"
  role = "${aws_iam_role.codecommit_cloudwatch_iam_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "codepipeline:StartPipelineExecution"
            ],
            "Resource": [
                "${var.codepipeline_project_arn}"
            ]
        }
    ]
}
EOF
}


resource "aws_cloudwatch_event_target" "codecommit_cloudwatch_event_target" {
  rule      = "${aws_cloudwatch_event_rule.codecommit_cloudwatch_event_rule.name}"
  target_id = "CodePipeline"
  arn       = "${var.codepipeline_project_arn}"
  role_arn  = "${aws_iam_role.codecommit_cloudwatch_iam_role.arn}"
}

