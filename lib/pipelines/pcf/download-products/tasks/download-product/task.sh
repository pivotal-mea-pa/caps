#!/bin/bash

[[ -n "$TRACE" ]] && set -x
set -eu

TILE_FILE_PATH=`find ./pivnet-product -name *.pivotal | sort | head -1`
if [[ -n "$TILE_FILE_PATH" ]]; then

  STEMCELL_VERSION=$(
    cat ./pivnet-product/metadata.json |
    jq --raw-output \
      '
      [
        .Dependencies[]
        | select(.Release.Product.Name | contains("Stemcells"))
        | .Release.Version
      ]
      | map(split(".") | map(tonumber))
      | transpose | transpose
      | max // empty
      | map(tostring)
      | join(".")
      '
  )

  if [ -n "$STEMCELL_VERSION" ]; then

    set +e
    diagnostic_report=$(
      om \
        --target https://$OPSMAN_HOST \
        --client-id "${OPSMAN_CLIENT_ID}" \
        --client-secret "${OPSMAN_CLIENT_SECRET}" \
        --username "$OPSMAN_USERNAME" \
        --password "$OPSMAN_PASSWORD" \
        --skip-ssl-validation \
        curl --silent --path "/api/v0/diagnostic_report"
    )
    if [[ $? -eq 0 ]]; then
      stemcell=$(
        echo $diagnostic_report |
        jq \
          --arg version "$STEMCELL_VERSION" \
          --arg glob "$IAAS" \
        '.stemcells[] | select(contains($version) and contains($glob))'
      )
    else
      echo "Ops Manager has not been set so proceeding with stemcell download..."
      stemcell=""
    fi
    set -e

    if [[ -z "$stemcell" ]]; then
      echo "Downloading stemcell $STEMCELL_VERSION"
      cd ./pivnet-product

      product_slug=$(
        jq --raw-output \
          '
          if any(.Dependencies[]; select(.Release.Product.Name | contains("Stemcells for PCF (Windows)"))) then
            "stemcells-windows-server"
          else
            "stemcells"
          end
          ' < ./metadata.json
      )

      pivnet-cli login --api-token="$PIVNET_API_TOKEN"
      
      set +e
      pivnet-cli download-product-files -p "$product_slug" -r $STEMCELL_VERSION -g "*${IAAS}*" --accept-eula
      if [[ $? -ne 0 ]]; then
        set -e

        # Download stemcell from bosh.io
        case "$IAAS" in
          google)
            stemcell_download_url=https://s3.amazonaws.com/bosh-gce-light-stemcells/light-bosh-stemcell-${STEMCELL_VERSION}-google-kvm-ubuntu-xenial-go_agent.tgz
            ;;
          aws)
            stemcell_download_url=https://s3.amazonaws.com/bosh-aws-light-stemcells/light-bosh-stemcell-${STEMCELL_VERSION}-aws-xen-hvm-ubuntu-xenial-go_agent.tgz
            ;;
          azure)
            stemcell_download_url=https://s3.amazonaws.com/bosh-core-stemcells/azure/bosh-stemcell-${STEMCELL_VERSION}-azure-hyperv-ubuntu-xenial-go_agent.tgz
            ;;
          vsphere)
            stemcell_download_url=https://s3.amazonaws.com/bosh-core-stemcells/vsphere/bosh-stemcell-${STEMCELL_VERSION}-vsphere-esxi-ubuntu-xenial-go_agent.tgz
            ;;
          openstack)
            stemcell_download_url=https://s3.amazonaws.com/bosh-core-stemcells/openstack/bosh-stemcell-${STEMCELL_VERSION}-openstack-kvm-ubuntu-xenial-go_agent.tgz
            ;;
          *)
            echo "ERROR! Unknown IAAS - $IAAS."
            exit 1
            ;;
        esac

        curl -OL $stemcell_download_url
      else
        set -e
      fi

      if [ ! -f "$(find ./ -name *.tgz)" ]; then
        echo "Stemcell file not found!"
        exit 1
      fi
      cd -
    fi
  fi

  unzip $TILE_FILE_PATH metadata/*
  PRODUCT_NAME="$(cat metadata/*.yml | grep '^name' | cut -d' ' -f 2)"
else
  PRODUCT_NAME=${NAME}
fi

tar cvzf pivnet-product.tgz ./pivnet-product

#
# Upload product metadata, tile and stemcell to local s3 repo
#
mc config host add auto ${AUTOS3_URL} ${AUTOS3_ACCESS_KEY} ${AUTOS3_SECRET_KEY}

VERSION=$(cat ./pivnet-product/metadata.json | jq --raw-output '.Release.Version')
PRODUCT_VERSION=${NAME}_${VERSION}

# Keep only the given number of most recent versions
PRODUCT_VERSIONS=$(mc ls --recursive auto/${BUCKET}/downloads \
  | sort -r \
  | awk "/ ${NAME}_/{ print \$5 }")

NUM_VERSIONS=$(echo "${PRODUCT_VERSIONS}" | wc -l)
if [[ ${NUM_VERSIONS} -gt 3 ]]; then
  for v in $(echo "${PRODUCT_VERSIONS}" | head -$((${NUM_VERSIONS}-${MIN_VERSIONS_TO_KEEP}))); do
    mc rm auto/${BUCKET}/downloads/${v}
  done
fi

# Upload new files
mc cp ./pivnet-product.tgz auto/${BUCKET}/downloads/${PRODUCT_VERSION}_${PRODUCT_NAME}.tgz

# Create placeholder versions file if one does not exist
set +e
mc ls auto/${BUCKET}/downloads | grep " versions-" 2>&1 >/dev/null
if [[ $? -ne 0 ]]; then
  touch versions-0
  mc cp ./versions-0 auto/${BUCKET}/downloads/versions-0
fi
