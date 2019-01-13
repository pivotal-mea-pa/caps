#!/bin/bash

exec 2> >(tee get_opsman_image_archive.log 2>&1 >/dev/null)

set -exu

opsman_image_archive=$(find ./pivnet-download -name "*.tgz" | sort | head -1)
tar xzf $opsman_image_archive

# us: ops-manager-us/pcf-gcp-1.9.2.tar.gz -> ops-manager-us/pcf-gcp-1.9.2.tar.gz
opsman_bucket_path=$(grep -i 'us:.*.tar.gz' pivnet-product/*GCP.yml | cut -d' ' -f2)

# ops-manager-us/pcf-gcp-1.9.2.tar.gz -> opsman-pcf-gcp-1-9-2
opsman_image_name=$(echo $opsman_bucket_path | sed 's%.*/\(.*\).tar.gz%opsman-\1%' | sed 's/\./-/g')

echo "{\"image_name\":\"$opsman_image_name\",\"bucket_path\":\"$opsman_bucket_path\"}"
