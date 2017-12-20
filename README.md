# Setting up and running Concourse pipelines for Java apps in air-gapped environments

When a Concourse pipeline is running in an air-gapped environment it only has access to built-in resource and task images such as `git`, `cf` or `s3`. Access to images in public repositories such as Docker Hub is prohibited. As a result, pipelines that rely on such images require a workaround. 

Suggested approach in this case is to use images from private S3 bucket accessible from the air-gapped environment. It requires three steps that this repository demonstrates.

First step, is to run `upload-offline-resource` pipeline for each image that would be required for the build pipeline. It shall be ran in the environment that has Internet access to pull resources. Is the sample pipeline defined in `pipeline.yml` file we use external image for `Maven` builds and this is the resource we need to get.

Second step, is to upload resources obtained in the previous step to a private S3 bucket accessible from the air-gapped environment. This is an environment-specific task and most likely involves manual steps.

Third step, is to configure build pipeline for a target application to use images from the private S3 bucket. The sample pipeline in the `ci` demonstrates this approach.

## To configure and run pipeline to load Maven Docker image to S3.

First, make sure that the `offline-resources/maven-image.yml` contains values that correspond to the desired image.

Second, create `credentials.yml` file by copying `credentials-template.yml` and specifying values for your environment. At this stage make sure that the S3 credentials refer to the bucket where you want images to be uploaded. Note that it might be a temporary S3 bucket from which you could download images and put them in the private S3 bucket later.

```bash
fly -t ci-target login -c <URL of the Concourse instance>
fly -t ci-target set-pipeline -c offline-resources/upload-offline-resource.yml -p upload-offline-resource -l <Path to credentials.yml> -l offline-resources/maven-image.yml
fly -t ci-target unpause-pipeline -p upload-offline-resource
fly -t ci-target trigger-job --job upload-offline-resource/download-and-package-image
```

To upload more images create corresponding `yml` file (e.g. `gradle-image.yml`) with details of target image and execute commands again specifying this file instead of `maven-image.yml`.

## To configure and depoy a sample pipeline

The sample is a basic Web app that uses Maven as a build tool. Before deploying the pipeline it is necessary to update configuration in the `credentials.yml` created on the previous step.

Make sure to define URL and branch for the Git repository from which to take the source code. Note that it has to have `ci` directory in it as the pipeline depends on it.

In air-gapped environment it is also necessary to specify configuration of Maven repositories to use during the build. The pipeline will make sure that these repositories are used by creating custom `settings.xml`.

Last, define the artifact name and packaging based on the `pom.xml` of the project being built. In case of this sample it is `app` and `war` correspondingly.

```bash
fly -t ci-target set-pipeline -c ci/pipeline.yml -p sample-pipeline -l <Path to credentials.yml>
fly -t ci-target unpause-pipeline -p sample-pipeline
```