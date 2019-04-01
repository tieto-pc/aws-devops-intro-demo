# AWS DevOps Intro Demonstration  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [Introduction](#introduction)
- [High Level Demonstration Steps](#high-level-demonstration-steps)
- [Prerequisites](#prerequisites)
- [Upload Your SSH Public Key for Using CodeCommit](#upload-your-ssh-public-key-for-using-codecommit)
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

- You need to deploy the [aws-ecs-fargate-demo](https://github.com/tieto-pc/aws-ecs-fargate-demo) project first since it provides the ECR that this DevOps demonstration uses when it pushes the new Docker image to ECR.
- You need to upload your SSH public key to AWS as instructed in chapter "Upload Your SSH Public Key for Using CodeCommit".


# Upload Your SSH Public Key for Using CodeCommit

Follow instructions given in [Setup for HTTPS Users Using Git Credentials](https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-gc.html). What you have to do is:
- Upload the SSH public key to your IAM user.
- Edit Local SSH Configuration: Add the SSH Key ID and the ssh private key reference to your ssh config file.


# CodeCommit

TODO

# CodeBuild

TODO


# Demonstration Manuscript

1. Do prerequisites as instructed above in chapter "Prerequisites".
2. Install [Terraform](https://www.terraform.io/). You might also like to add Terraform support for your favorite editor (e.g. there is a Terraform extension for VS Code).
3. Install [AWS command line interface](https://aws.amazon.com/cli).
4. Clone this project: git clone https://github.com/tieto-pc/aws-devops-intro-demo.git
5. Configure the terraform backend as instructed in chapter "Terraform Backend". Create AWS credentials file as instructed in the same chapter.
6. Open console in [dev](terraform/envs/dev) folder. Give commands
   1. ```terraform init``` => Initializes the Terraform backend state.
   2. ```terraform get``` => Gets the terraform modules of this project.
   3. ```terraform plan``` => Gives the plan regarding the changes needed to make to your infra. **NOTE**: always read the plan carefully!
   4. ```terraform apply``` => Creates the delta between the current state in the infrastructure and your new state definition in the Terraform configuration files.
   5. You should now have CodeCommit repository and CodeBuild environments. Check these services in AWS Console.
7. Configure the CodeCommit repository to the Java app's remote:
```text
[remote "codecommit"]
	url = ssh://<CODE-COMMIT-REPO> (as given in the repository page)
	fetch = +refs/heads/*:refs/remotes/codecommit/*
```
8. Push the Java app git master branch to the new CodeCommit repository: git push codecommit master.
9. Check in AWS CodeCommit Dashboard that you see the code there.


