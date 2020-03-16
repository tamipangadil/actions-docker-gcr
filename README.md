# actions-docker

Opinionated GitHub Actions for common Docker workflows

Fork from https://github.com/urcomputeringpal/actions-docker

## Opinions (expressed via default environment variables)

- [`REGISTRY=gcr.io`](https://gcr.io)
- `IMAGE=$GITHUB_REPOSITORY`
  - (Expects a Google Cloud Project named after your GitHub username)
- `TAG=$GITHUB_SHA`
- `LATEST=true`
- `TAG_AS_GITHUB_TAG=false`
- `ARGS=left empty`
  - Add more docker build args
  - `--build-arg arg1=test1 --build-arg arg2=test2`
- `DEFAULT_BRANCH_TAG=true`
- `WORKDIR=.`
  - Custom directory that has the project `Dockerfile`

## Usage

### Google Container Registry Setup

- If you haven't already, [create a Google Cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#creating_a_project) named after your GitHub username and follow the [Container Registry Quickstart](https://cloud.google.com/container-registry/docs/quickstart#before-you-begin).
- [Create a Service Account](https://cloud.google.com/iam/docs/creating-managing-service-accounts#creating_a_service_account) named after your GitHub repository.
- [Add the _Cloud Build Service Account_](https://cloud.google.com/iam/docs/granting-roles-to-service-accounts#granting_access_to_a_service_account_for_a_resource) role to this Service Account.
- [Generate a key for this Service Account](https://cloud.google.com/iam/docs/creating-managing-service-account-keys#creating_service_account_keys). Download a JSON key when prompted.
- Create a Secret on your repository named `GCLOUD_SERVICE_ACCOUNT_KEY` (Settings > Secrets) with the contents of:

```shell
# Linux
cat path-to/key.json | base64 -w 0

# MacOS
cat path-to/key.json | base64 -b 0
```

- That's it! The GitHub Actions in this repository read this Secret and provide the correct values to the Docker daemon by default if present. If a Secret isn't present, `build` _may_ succeed but `push` will return an error!

### Build and push images for each commit

Add the following to `.github/workflows/docker.yaml`:

```yaml
name: Docker

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v1

      - name: Docker Build
        uses: tamipangadil/actions-docker-gcr/build@master

      - name: Docker Push
        uses: tamipangadil/actions-docker-gcr/push@master
        env:
          GCLOUD_SERVICE_ACCOUNT_KEY: ${{ secrets.GCLOUD_SERVICE_ACCOUNT_KEY }}
```

### Specify a different Registry, Project & image name, and other environment variables

```yaml
    [...]
    steps:
      - uses: actions/checkout@v1

      - name: Docker Build
        uses: tamipangadil/actions-docker-gcr/build@master
        env:
          IMAGE: my-project/my-image
          GCLOUD_REGISTRY: eu.gcr.io
          LATEST: false
          ARGS: ""
          WORKDIR: path/to/custom/directory
          TAG: "v1.0"

      - name: Docker Push
        uses: tamipangadil/actions-docker-gcr/push@master
        env:
          IMAGE: my-project/my-image
          GCLOUD_REGISTRY: eu.gcr.io
          GCLOUD_SERVICE_ACCOUNT_KEY: ${{ secrets.GCLOUD_SERVICE_ACCOUNT_KEY }}
          LATEST: false
          TAG: "v1.0"
```
