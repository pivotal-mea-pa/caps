#!/bin/bash

exec 2> >(tee get_opsman_image_archive.log 2>&1 >/dev/null)

set -exu

opsman_image_archive=$(find ./pivnet-download -name *.tgz | sort | head -1)
echo "{\"path\":\"$opsman_image_archive\"}"