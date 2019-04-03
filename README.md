# AWS DevOps Intro Demonstration  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [Introduction](#introduction)
- [High Level Demonstration Steps](#high-level-demonstration-steps)
- [Prerequisites](#prerequisites)
- [Upload Your SSH Public Key for Using CodeCommit](#upload-your-ssh-public-key-for-using-codecommit)
- [Developing With New Cloud Services](#developing-with-new-cloud-services)
- [CodeCommit](#codecommit)
- [Local CodeBuild](#local-codebuild)
- [CodeBuild](#codebuild)
- [CodePipeline](#codepipeline)
- [Demonstration Manuscript](#demonstration-manuscript)


# Introduction

This project demonstrates how to setup and use AWS DevOps tools [CodeCommit](https://aws.amazon.com/codecommit/) (a Git repository), [CodeBuild](https://aws.amazon.com/codebuild/) (a Continous Integration tool) and [CodePipeline](https://aws.amazon.com/codepipeline/) (a Continuous Develivery pipeline). All artefacts are created as infrastructure as code (IaC) using [Terraform](https://www.terraform.io/). 

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


# Developing With New Cloud Services

It is a best practice that if you are creating infrastructure as code using new cloud services it is usually a wise move to create the cloud entities first manually using the portal, then examine how the cloud provider's wizards (behind the scene) created the entities using the services and then try to create the same entities using IaC. CodeCommit part of this demonstration was so simple that I just created it using Terraform. But to understand CodeBuild and CodePipeline better I first created an AWS CodePipeline spec (and CodeBuild) using AWS Portal, and used the manual pipeline to build the Java application I'm using in this demonstration. Once I understood how everything is working I created the same entities using IaC.


# CodeCommit

CodeCommit is basically just a Git repository. We have created the repository using Terraform. The repository provides instructions how to clone/push source code from/to repository. CodeBuild uses CodeCommit repository to fetch source code and build instructions.


# Local CodeBuild

When I was experimenting with the manually created CodePipeline / CodeBuild I was debugging the CodeBuild's Build spec. The development cycle was a bit annoying - edit build spec, push to CodeCommit, wait that CodePipeline gets triggered, wait that pipeline tells CodeBuild to build the project and check the results. Therefore I googled if there is some way to debug the build spec with a faster development cycle. I found this: [Announcing Local Build Support for AWS CodeBuild](https://aws.amazon.com/blogs/devops/announcing-local-build-support-for-aws-codebuild/). It was pretty cool. You just had to clone the the local codebuild repo, build the Docker image and you are good to go to use that Docker image as your local CodeBuild service. I cloned the demo repo and ran the local CodeBuild and it succesfully build the demo app and created the artifact into my local artifact directory (you have to create the directory, of course - see instructions in the link above).

NOTE:
- You have to create aws-scripts directory in the root of this project and download the codebuild_build.sh file there.
- The codebuild_build.sh is needed by script run-local-codebuild.sh (local CodeBuild tool).
- I'm not including the aws script in this repo just in case that no-one complains that I have proprietary components in our repo. You can download the script that should be in this directory from AWS:
- See: https://aws.amazon.com/blogs/devops/announcing-local-build-support-for-aws-codebuild/
- Download the script like: wget https://raw.githubusercontent.com/aws/aws-codebuild-docker-images/master/local_builds/codebuild_build.sh

After the AWS provided demo I tried the local CodeBuild tool with my own project [java-simple-rest-demo-app
](https://github.com/tieto-pc/java-simple-rest-demo-app) which I'm about to use as a demo app when demonstrating the AWS PipeLine tools. Holy Moly, it worked (except I got the exact same error "UPLOAD_ARTIFACTS State: FAILED => no matching artifact paths found" as with real AWS service - but at least this error is now easier to debug locally, but at least the compile, build, run unit tests phases went smoothly).




# CodeBuild

TODO

# CodePipeline

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


