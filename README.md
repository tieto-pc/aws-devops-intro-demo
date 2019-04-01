# AWS DevOps Intro Demonstration  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [Introduction](#introduction)
- [High Level Demonstration Steps](#high-level-demonstration-steps)
- [Prerequisites](#prerequisites)
- [CodeCommit](#codecommit)
- [CodeBuild](#codebuild)
- [Demonstration Manuscript](#demonstration-manuscript)


# Introduction

This project demonstrates how to setup and use AWS DevOps tools [CodeCommit](https://aws.amazon.com/codecommit/) (a Git repository) and [CodeBuild](https://aws.amazon.com/codebuild/) (a Continous Integration tool). All artefacts are created as infrastructure as code (IaC) using [Terraform](https://www.terraform.io/). 

# High Level Demonstration Steps

The demonstration has the following high level steps:

1. The demonstration creates a [CodeCommit](https://aws.amazon.com/codecommit/) repository.
2. The demonstration uses code in an existing Github project - [java-simple-rest-demo-app
](https://github.com/tieto-pc/java-simple-rest-demo-app) and pushes the code to the AWS CodeCommit repository (we could have used the original Github repository but steps #1-#2 are used for demonstration purposes).
3. The demonstration builds the Java application using [CodeBuild](https://aws.amazon.com/codebuild/). CodeBuild also runs unit tests and then builds the Docker image from the Java application and pushes the new Docker image to AWS [ECR](https://aws.amazon.com/ecr/).
4. The new Docker image can be used to deploy new version of the application to [aws-ecs-fargate-demo
](https://github.com/tieto-pc/aws-ecs-fargate-demo) which uses the Docker image from the AWS ECR registry.


# Prerequisites

You need to deploy the [aws-ecs-fargate-demo](https://github.com/tieto-pc/aws-ecs-fargate-demo) project first since it provides the ECR that this DevOps demonstration uses when it pushes the new Docker image to ECR.



# CodeCommit

TODO

# CodeBuild

TODO


# Demonstration Manuscript

TODO
