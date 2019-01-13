#!/bin/bash

set -exu

opsman_image_name='${opsman_image_name}'
opsman_bucket_path='${opsman_bucket_path}'

if [[ -z $(gcloud compute images list | grep $opsman_image_name) ]]; then

  echo "creating image ${opsman_image_name}"
  gcloud compute images create $opsman_image_name \
    --family pcf-opsman \
    --source-uri "gs://${opsman_bucket_path}"
else
  echo "image ${opsman_image_name} already exists"
fi
