#!/bin/bash

[[ -n "$TRACE" ]] && set -x
set -eu

TILE_FILE_PATH=`find ./pivnet-product -name *.pivotal | sort | head -1`

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
  diagnostic_report=$(
    om \
      --target https://$OPSMAN_HOST \
      --client-id "${OPSMAN_CLIENT_ID}" \
      --client-secret "${OPSMAN_CLIENT_SECRET}" \
      --username "$OPS_MGR_USR" \
      --password "$OPS_MGR_PWD" \
      --skip-ssl-validation \
      curl --silent --path "/api/v0/diagnostic_report"
  )

  stemcell=$(
    echo $diagnostic_report |
    jq \
      --arg version "$STEMCELL_VERSION" \
      --arg glob "$IAAS" \
    '.stemcells[] | select(contains($version) and contains($glob))'
  )

  if [[ -z "$stemcell" ]]; then
    echo "Downloading stemcell $STEMCELL_VERSION"

    product_slug=$(
      jq --raw-output \
        '
        if any(.Dependencies[]; select(.Release.Product.Name | contains("Stemcells for PCF (Windows)"))) then
          "stemcells-windows-server"
        else
          "stemcells"
        end
        ' < pivnet-product/metadata.json
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
        # aws)
        #   ;;
        # azure)
        #   ;;
        # vsphere)
        #   ;;
        # openstack)
        #   ;;
        *)
          echo "ERROR! Unknown IAAS - $IAAS."
          exit 1
          ;;
      esac

      curl -OL $stemcell_download_url
    else
      set -e
    fi

    STEMCELL_FILE_PATH=`find ./ -name *.tgz`

    if [ ! -f "$STEMCELL_FILE_PATH" ]; then
      echo "Stemcell file not found!"
      exit 1
    fi
  fi
fi

#
# Upload product metadata, tile and stemcell to local s3 repo
#
mc config host add auto ${AUTOS3_URL} ${AUTOS3_ACCESS_KEY} ${AUTOS3_SECRET_KEY}

NAME=$(echo "${TILE_FILE_PATH##*/}" | sed "s|\(.*\)-[0-9]*\.[0-9]*\.[0-9]*.*|\1|")
VERSION=$(cat ./pivnet-product/metadata.json | jq --raw-output '.Release.Version')

PRODUCT_NAME=${NAME}_${VERSION}

# mc rm --force --recursive --older-than=7 auto/${BUCKET}/downloads/${NAME}_*
mc cp pivnet-product/metadata.json auto/${BUCKET}/downloads/${PRODUCT_NAME}/metadata.json

TILE_FILE_NAME=${TILE_FILE_PATH##*/}
mc cp ${TILE_FILE_PATH} auto/${BUCKET}/downloads/${PRODUCT_NAME}/${TILE_FILE_NAME}

if [[ -n ${STEMCELL_FILE_PATH} ]]; then
  STEMCELL_FILE_NAME=${STEMCELL_FILE_PATH##*/}
  mc cp ${STEMCELL_FILE_PATH} auto/${BUCKET}/downloads/${PRODUCT_NAME}/${STEMCELL_FILE_NAME}
fi
