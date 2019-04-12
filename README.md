# AWS DevOps Intro Demonstration  <!-- omit in toc -->


# Table of Contents  <!-- omit in toc -->
- [Introduction](#introduction)
- [High Level Demonstration Steps](#high-level-demonstration-steps)
- [Prerequisites](#prerequisites)
- [Upload Your SSH Public Key for Using CodeCommit](#upload-your-ssh-public-key-for-using-codecommit)
- [Developing With New Cloud Services](#developing-with-new-cloud-services)
- [CodeCommit](#codecommit)
- [Local CodeBuild](#local-codebuild)
- [S3 Buckets and CloudWatch Logs](#s3-buckets-and-cloudwatch-logs)
- [CodeBuild](#codebuild)
- [CodePipeline](#codepipeline)
- [Demonstration Manuscript](#demonstration-manuscript)


# Introduction

This project demonstrates how to setup and use AWS DevOps tools [CodeCommit](https://aws.amazon.com/codecommit/) (a Git repository), [CodeBuild](https://aws.amazon.com/codebuild/) (a Continous Integration tool) and [CodePipeline](https://aws.amazon.com/codepipeline/) (a Continuous Develivery pipeline). All artifacts are created using infrastructure as code (IaC) using [Terraform](https://www.terraform.io/). 

The AWS solution is depicted in the diagram below.

![AWS DevOps Demo](docs/AWS-devops-demo.png?raw=true "AWS DevOps Demo")




# High Level Demonstration Steps

The demonstration has the following high level steps:

1. The demonstration creates a [CodeCommit](https://aws.amazon.com/codecommit/) repository.
2. The demonstration uses code in an existing Github project - [java-simple-rest-demo-app](https://github.com/tieto-pc/java-simple-rest-demo-app) and pushes the code to the AWS CodeCommit repository (we could have used the original Github repository but steps #1-#2 are used for demonstration purposes).
3. The demonstration builds the Java application using [CodeBuild](https://aws.amazon.com/codebuild/). CodeBuild also runs unit tests and then builds the Docker image from the Java application and pushes the new Docker image to AWS [ECR](https://aws.amazon.com/ecr/) - demonstration [aws-ecs-fargate-demo
](https://github.com/tieto-pc/aws-ecs-fargate-demo) provides the ECR registry.
4. The new Docker image can be used to deploy a new version of the application to [aws-ecs-fargate-demo](https://github.com/tieto-pc/aws-ecs-fargate-demo).


# Prerequisites

- You need to deploy the [aws-ecs-fargate-demo](https://github.com/tieto-pc/aws-ecs-fargate-demo) project first since it provides the ECR that this DevOps demonstration uses when it pushes the new Docker image to ECR.
- You need to clone the Java example project [java-simple-rest-demo-app
](https://github.com/tieto-pc/java-simple-rest-demo-app) and push the code to CodeCommit for the demonstration.
- You need to upload your SSH public key to AWS as instructed in chapter "Upload Your SSH Public Key for Using CodeCommit". 


# Upload Your SSH Public Key for Using CodeCommit

Follow instructions given in [Setup for HTTPS Users Using Git Credentials](https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-gc.html). What you have to do is:
- Upload the SSH public key to your IAM user.
- Edit Local SSH Configuration: Add the SSH Key ID and the ssh private key reference to your ssh config file.


# Developing With New Cloud Services

Let's talk about how to create new cloud services as infrastructure as code before we continue.

When you are creating infrastructure as code using new cloud services it is usually a wise move to create the cloud entities first manually using the portal, then examine how the cloud provider's wizards (behind the curtains) created the entities using the services and then try to create the same entities using IaC. 

CodeCommit part of this demonstration was so simple that I just created it using Terraform (except the triggering mechanism - more about that later). But to understand CodeBuild and CodePipeline better I first created the entities using AWS Portal, and used those entities to build the Java application I'm using in this demonstration.

Once everything was working properly with the manually created entities I exported the AWS CodePipeline and CodeBuild projects as CloudFormation stack json descriptions to a file:

```bash
AWS_PROFILE=YOUR-AWS-PROFILE aws codepipeline get-pipeline --name YOUR-MANUAL-CODEPIPELINE-PROJECT-NAME > manual-codepipeline-description.txt
AWS_PROFILE=YOUR-AWS-PROFILE aws codebuild batch-get-projects --name YOUR-MANUAL-CODEBUILD-PROJECT-NAME --output json > manual-codebuild-description.txt
```

Now I had the descriptions of the manually created projects nicely in a file. Then I just converted the entities in those files into Terraform resources. This is a nice way to figure out what magic AWS Portal is doing behind the scenes.

Of course this was a happy day scenario. In real life there are always bits and pieces missing. The portal wizards create all kinds of stuff behind the scenes that you have to figure out yourself. One example. When I had the automated CodePipeLine project and CodeBuild projects ready and I was testing the pipeline I was wondering why the CodePipeline that was created using the portal wizard got automatically triggered but my CodePipeline that I created using Terraform IaC was not. Consult the book of knowledge - Google - and I got the answer: [Start a Pipeline Execution in CodePipeline](https://docs.aws.amazon.com/codepipeline/latest/userguide/pipelines-about-starting.html): *"When you use the console to create a pipeline that has a CodeCommit source repository or Amazon S3 source bucket, CodePipeline creates an Amazon CloudWatch Events rule that starts your pipeline when the source changes."* So, the portal wizards create all kinds of service roles, policies and triggering mechanisms to make your life easier when you are creating the service entities using the portal. Portal makes things often so easy that some cloud developers create the whole cloud native system using the portal - big mistake. I once audited a customer's big data system that was created using the portal - no documentation how the system was created, no way to reproduce the equivalent system for development or testing automatically. The only way to make a reproducible cloud system is to use infrastructure as code. 

So, the lesson of the story is: Use the portal to explore and learn new cloud services, but create the final system using infrastructure as code. In the example above I used the portal to see what kind of triggering mechanism was created by the portal wizard and then I created the similar mechanism using Terraform code.


# CodeCommit

The [codecommit terraform module](terraform/modules/codecommit) hosts the [CodeCommit](https://aws.amazon.com/codecommit/) repository and the triggering mechanism.

CodeCommit is basically just a Git repository. I have created the repository using Terraform. CodeBuild uses CodeCommit repository to fetch source code and build specifications.

I added into the codecommit module also the triggering mechanism I talked about in the previous chapter. The triggering mechanism is basically just a [CloudWatch Event Rule](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-events-rule.html) that gets triggered when a new commit is pushed into the repository - the rule then triggers the CodePipeline project.


# Local CodeBuild

When I was experimenting with the manually created CodePipeline / CodeBuild I was debugging the CodeBuild's Build spec. The development cycle was a bit annoying - edit build spec, push to CodeCommit, start CodePipeline, wait that CodePipeline tells CodeBuild to build the project and check the results. Therefore I googled if there is some way to debug the build spec with a faster development cycle. I found this: [Announcing Local Build Support for AWS CodeBuild](https://aws.amazon.com/blogs/devops/announcing-local-build-support-for-aws-codebuild/). It was pretty cool. You just had to clone the local codebuild repo, build the Docker image and you are good to go to use that Docker image as your local CodeBuild service. I cloned the demo repo and ran the local CodeBuild and it succesfully build the demo app and created the artifact into my local artifact directory.

Instructions:
- Go to project [java-simple-rest-demo-app](https://github.com/tieto-pc/java-simple-rest-demo-app).
- Download the codebuild_build.sh file: 
    - See: https://aws.amazon.com/blogs/devops/announcing-local-build-support-for-aws-codebuild/
    - Download the script: ```wget https://raw.githubusercontent.com/aws/aws-codebuild-docker-images/master/local_builds/codebuild_build.sh```
- The codebuild_build.sh is needed by script [run-local-codebuild-build-and-test.sh](https://github.com/tieto-pc/java-simple-rest-demo-app/blob/master/run-local-codebuild-build-and-test.sh).
- You need to create a build specification file for the CodeBuild: [buildspec_build_and_test.yml](https://github.com/tieto-pc/java-simple-rest-demo-app/blob/master/codebuild/buildspec_build_and_test.yml) .
- You need to create the build environment. I used [Ubuntu 18 Standard build environment Docker image](https://github.com/aws/aws-codebuild-docker-images/tree/master/ubuntu/standard/1.0). Build it, e.g. ```docker build -t aws/codebuild/ubuntu:18 . ```.
- Once everything is ready try to run the local CodeBuild: ```./run-local-codebuild-build-and-test.sh```

After the AWS provided demo I tried the local CodeBuild tool with my own project [java-simple-rest-demo-app
](https://github.com/tieto-pc/java-simple-rest-demo-app) which I'm using as a demo app when demonstrating the AWS DevOps tools in this project. I had to debug the build specification a bit but finally I got it working. After the build was ok in local CodeBuild I verified that it works the same way in the real AWS CodeBuild service. (By the way. I spent quite a long time figuring out why normal ```gradle build``` didn't create the application jar in the local or AWS CodeBuild environment - as in my host; I had to create a workaround: first run gradle bootJar and take the application jar and only after that run the tests - otherwise Gradle didn't build the application jar in the CodeBuild environment - something I need to figure out later.)


# S3 Buckets and CloudWatch Logs

I created three S3 buckets for the DevOps environment:
- Caches (used by CodeBuild to cache builds - actually there was some issues with rights - I need to figure this out later - anyway, skipping caches didn't seem to make any difference to the build process time).
- Artifacts (used by CodePipeline to upload application jar for further phases).
- Logs (for various logging purposes).

I also created A CloudWatch Log group but I later realized that Terraform does not support at the moment the CloudWatch logsConfig configuration in CodeBuild projects - I left the log S3 and CloudWatch Log group in the Terraform modules anyway - maybe the support will come in the near future and I update the logsConfig to the CodeBuild then.



# CodeBuild

The [codebuild terraform module](modules/codebuild) has two projects:

1. **Build and test Java project.** The project uses CodeCommit repo as the source and then calls the Java project's build specification file to run the build and test process: [buildspec_build_and_test.yml](https://github.com/tieto-pc/java-simple-rest-demo-app/blob/master/codebuild/buildspec_build_and_test.yml). CodePipeline pushes the created application jar into S3 artifacts bucket.

2. **Build Docker Image project.** The project fetches the application jar from the S3 bucket and bakes the application jar into a Docker image. This project uses build specification: [buildspec_build_docker_image.yml](https://github.com/tieto-pc/java-simple-rest-demo-app/blob/master/codebuild/buildspec_build_docker_image.yml).

I could have aggregated both steps into the same CodeBuild project (would have been more efficient) but I wanted to demonstrate how to create modular CodeBuild projects that are orchestrated by CodePipeline. The current design has some advantages, though: it is more modular therefore making the development and debugging both projects independent from each other.

I added into the same Terraform module also the service IAM role and and policy for CodeBuild - basically allowing CodeBuild to interact with S3 bucket (upload/download application jar) and ECR (push Docker image).


# CodePipeline

The [codepipeline terraform module](modules/codepipeline) has three stages:

1. **Source stage** which pulls sources from CodeCommit.

2. **Build and test stage** which builds the app jar (using CodeBuild build and test project, action 1) and then uploads the application jar into S3 artifact bucket (action 2).

3. **Docker image stage** which bakes the Docker image (using CodeBuild Docker image project).

The CodePipeline project is therefore an orchestrator which uses CodeBuild projects (providing the actual building instructions) to define the steps we have to walk through to get a new deployment. The deployment in this context means the new Docker image in ECR ready for someone else to take actions - the new Docker image could e.g. start a new CodePipeline project which actually deploys the new Docker image e.g. into the automatic test environment for end-to-end testing.


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
10. If everything went smoothly you should see the CodePipeline project triggered by the new commit. You might need to release the CodePipeline project the first time and then create a test commit to trigger the CodePipeline.


