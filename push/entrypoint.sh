#!/bin/bash

set -e

: ${GCLOUD_REGISTRY:=gcr.io}
: ${IMAGE:=$GITHUB_REPOSITORY}
: ${TAG:=$GITHUB_SHA}
: ${HEAD_TAG:=${GITHUB_REF/refs\/tags\//}}
: ${DEFAULT_BRANCH_TAG:=true}
: ${LATEST:=true}
: ${TAG_AS_GITHUB_TAG:=false}

if [ -n "${GCLOUD_SERVICE_ACCOUNT_KEY}" ]; then
  echo "Logging into gcr.io with GCLOUD_SERVICE_ACCOUNT_KEY..."
  echo ${GCLOUD_SERVICE_ACCOUNT_KEY} | base64 --decode --ignore-garbage > /tmp/key.json
  gcloud auth activate-service-account --quiet --key-file /tmp/key.json
  gcloud auth configure-docker --quiet
else
  echo "GCLOUD_SERVICE_ACCOUNT_KEY was empty, not performing auth" 1>&2
fi

docker push $GCLOUD_REGISTRY/$IMAGE:$TAG

if [ $TAG_AS_GITHUB_TAG = true ]; then
  docker push $GCLOUD_REGISTRY/$IMAGE:$HEAD_TAG
fi

if [ "$DEFAULT_BRANCH_TAG" = "true" ]; then
  BRANCH=$(echo $GITHUB_REF | rev | cut -f 1 -d / | rev)
  if [ "$BRANCH" = "master" ]; then # TODO
    docker push $GCLOUD_REGISTRY/$IMAGE:$BRANCH
    # Override: Allow to push the Latest tag too
    LATEST=true
  fi
fi

if [ $LATEST = true ]; then
  docker push $GCLOUD_REGISTRY/$IMAGE:latest
fi