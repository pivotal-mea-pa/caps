#!/bin/bash

exec 2> >(tee get_opsman_image_archive.log 2>&1 >/dev/null)

set -exu

opsman_image_archive=$(find ./pivnet-download -name "*.tgz" | sort | head -1)
tar xvzf $opsman_image_archive

# us: ops-manager-us/pcf-gcp-1.9.2.tar.gz -> ops-manager-us/pcf-gcp-1.9.2.tar.gz
pcf_opsman_bucket_path=$(grep -i 'us:.*.tar.gz' pivnet-product/*GCP.yml | cut -d' ' -f2)

# ops-manager-us/pcf-gcp-1.9.2.tar.gz -> opsman-pcf-gcp-1-9-2
pcf_opsman_image_name=$(echo $pcf_opsman_bucket_path | sed 's%.*/\(.*\).tar.gz%opsman-\1%' | sed 's/\./-/g')

if [[ -z $(gcloud compute images list | grep $pcf_opsman_image_name) ]]; then

  (>&2 echo "creating image ${pcf_opsman_image_name}")
  gcloud compute images create $pcf_opsman_image_name \
    --family pcf-opsman \
    --source-uri "gs://${pcf_opsman_bucket_path}" \
    2>&1 >> get_opsman_image_archive.log
else
  (>&2 echo "image ${pcf_opsman_image_name} already exists")
fi

echo "{\"image_name\":\"$pcf_opsman_image_name\"}"
