#!/bin/bash

set -e

: ${WORKDIR:=.}
: ${GCLOUD_REGISTRY:=gcr.io}
: ${IMAGE:=$GITHUB_REPOSITORY}
: ${ARGS:=} # Default: empty build args
: ${TAG:=$GITHUB_SHA}
: ${HEAD_TAG:=${GITHUB_REF/refs\/tags\//}}
: ${DEFAULT_BRANCH_TAG:=true}
: ${LATEST:=true}
: ${TAG_AS_GITHUB_TAG:=false}

docker build $ARGS -t $IMAGE:$TAG $WORKDIR
docker tag $IMAGE:$TAG $GCLOUD_REGISTRY/$IMAGE:$TAG

if [ $TAG_AS_GITHUB_TAG = true ]; then
  docker tag $IMAGE:$TAG $GCLOUD_REGISTRY/$IMAGE:$HEAD_TAG
fi

if [ "$DEFAULT_BRANCH_TAG" = "true" ]; then
  BRANCH=$(echo $GITHUB_REF | rev | cut -f 1 -d / | rev)
  if [ "$BRANCH" = "master" ]; then # TODO
    docker tag $IMAGE:$TAG $GCLOUD_REGISTRY/$IMAGE:$BRANCH
    # Override: Allow to tag as latest
    LATEST=true
  fi
fi

if [ $LATEST = true ]; then
  docker tag $IMAGE:$TAG $GCLOUD_REGISTRY/$IMAGE:latest
fi
