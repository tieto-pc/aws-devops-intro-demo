# AWS DevOps Intro Demonstration  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [WORK IN PROGRESS!](#work-in-progress)
- [Introduction](#introduction)
- [High Level Demonstration Steps](#high-level-demonstration-steps)
- [Prerequisites](#prerequisites)
- [Upload Your SSH Public Key for Using CodeCommit](#upload-your-ssh-public-key-for-using-codecommit)
- [Developing With New Cloud Services](#developing-with-new-cloud-services)
- [CodeCommit](#codecommit)
- [Local CodeBuild](#local-codebuild)
- [S3 Buckets and CloudWatch Logs](#s3-buckets-and-cloudwatch-logs)
- [Service Role](#service-role)
- [CodeBuild](#codebuild)
- [CodePipeline](#codepipeline)
- [Demonstration Manuscript](#demonstration-manuscript)



# WORK IN PROGRESS!

I'm actively working with this project and it is not yet ready. Once the project is ready I remove this chapter.


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

Let's talk about how to create new cloud services as infrastructure as code.

It is a best practice that if you are creating infrastructure as code using new cloud services it is usually a wise move to create the cloud entities first manually using the portal, then examine how the cloud provider's wizards (behind the scene) created the entities using the services and then try to create the same entities using IaC. 

CodeCommit part of this demonstration was so simple that I just created it using Terraform. But to understand CodeBuild and CodePipeline better I first created an AWS CodePipeline spec (and CodeBuild) using AWS Portal, and used the manual pipeline to build the Java application I'm using in this demonstration.

Once everything was working properly with the manually created services I exported the AWS CodePipeline and CodeBuild projects as CloudFormation stack json descriptions to a file:

```bash
AWS_PROFILE=YOUR-AWS-PROFILE aws codepipeline get-pipeline --name YOUR-MANUAL-CODEPIPELINE-PROJECT-NAME > manual-codepipeline-description.txt
AWS_PROFILE=YOUR-AWS-PROFILE aws codebuild batch-get-projects --name YOUR-MANUAL-CODEBUILD-PROJECT-NAME --output json > manual-codebuild-description.txt
```

Now I had the descriptions of the manually created projects nicely in a file. Then I just converted the entities in those files into Terraform resources. This is a nice way to figure out what magic AWS Portal is doing behind the scene.



# CodeCommit

CodeCommit is basically just a Git repository. We have created the repository using Terraform. The repository provides instructions how to clone/push source code from/to repository. CodeBuild uses CodeCommit repository to fetch source code and build instructions.


# Local CodeBuild

When I was experimenting with the manually created CodePipeline / CodeBuild I was debugging the CodeBuild's Build spec. The development cycle was a bit annoying - edit build spec, push to CodeCommit, wait that CodePipeline gets triggered, wait that pipeline tells CodeBuild to build the project and check the results. Therefore I googled if there is some way to debug the build spec with a faster development cycle. I found this: [Announcing Local Build Support for AWS CodeBuild](https://aws.amazon.com/blogs/devops/announcing-local-build-support-for-aws-codebuild/). It was pretty cool. You just had to clone the the local codebuild repo, build the Docker image and you are good to go to use that Docker image as your local CodeBuild service. I cloned the demo repo and ran the local CodeBuild and it succesfully build the demo app and created the artifact into my local artifact directory (you have to create the directory, of course - see instructions in the link above).

Instructions:
- Go to project [java-simple-rest-demo-app](https://github.com/tieto-pc/java-simple-rest-demo-app).
- Download the codebuild_build.sh file: 
    - See: https://aws.amazon.com/blogs/devops/announcing-local-build-support-for-aws-codebuild/
    - Download the script: ```wget https://raw.githubusercontent.com/aws/aws-codebuild-docker-images/master/local_builds/codebuild_build.sh```
- The codebuild_build.sh is needed by script [run-local-codebuild.sh](https://github.com/tieto-pc/java-simple-rest-demo-app/blob/master/run-local-codebuild.sh) (local CodeBuild tool).
- You need to create a build specification file for the CodeBuild: [buildspec_build_and_test.yml](https://github.com/tieto-pc/java-simple-rest-demo-app/blob/master/buildspec_build_and_test.yml) .
- You need to create the build environment. I used [Ubuntu 18 Standard build environment Docker image](https://github.com/aws/aws-codebuild-docker-images/tree/master/ubuntu/standard/1.0). Build it, e.g. ```docker build -t aws/codebuild/ubuntu:18 . ```.
- Once everything is ready try to run the local CodeBuild: ```./run-local-codebuild.sh```

After the AWS provided demo I tried the local CodeBuild tool with my own project [java-simple-rest-demo-app
](https://github.com/tieto-pc/java-simple-rest-demo-app) which I'm about to use as a demo app when demonstrating the AWS PipeLine tools. I had to debug the build specification a bit but finally I got it working. After the build was ok in local CodeBuild I verified that it works the same way in the real AWS CodeBuild service.


# S3 Buckets and CloudWatch Logs

I created three S3 buckets for the DevOps environment:
- Caches (used by CodeBuild to cache builds).
- Artifacts (used by CodePipeline to upload app jar for further phases).
- Logs (for various logging purposes).

I also created A CloudWatch Log group but I later realized that Terraform does not support at the moment the CloudWatch logsConfig configuration in CodeBuild projects - I left the log S3 and CloudWatch Log group to the Terraform modules anyway - maybe the support will come in the near future and I update the logsConfig to the CodeBuild then.


# Service Role

I created a Service role for CodeBuild. The role is injected to the CodeBuild module.


# CodeBuild

The CodeBuild module has two projects:

1. Build and test project which uses CodeCommit repo as the source and then calls the Java project's buildspec.yml build specification file to run the build and test process.

2. Docker Image project which creates the Docker image and bakes into it the application jar that the previous CodeBuild project created.



# CodePipeline

The CodePipeline has three stages:

1. Source stage which pulls sources from CodeCommit.

2. Build and test stage which builds the app jar (using CodeBuild build and test project) and then uploads the application jar into S3 artifact bucket.

3. Docker image stage which bakes the Docker image (using CodeBuild Docker image project).


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


