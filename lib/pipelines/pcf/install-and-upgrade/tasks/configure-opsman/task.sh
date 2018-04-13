#!/bin/bash

source ~/scripts/opsman-func.sh

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

start_time=$(date +%s)
while [[ true ]]; do

  status=$(opsman::check_available "https://$OPSMAN_HOST")
  if [[ $status == "available" ]]; then
    exit
  elif [[ $status == "The application has not yet been set up."* ]]; then
    break
  fi

  sleep 5
  time_now=$(date +%s)

  ss=$(($time_now-$start_time))
  h=$(($ss/3600))
  m=$(($ss/60-$h*60))
  s=$(($ss-$m*60-$h*3600))
  time_elapsed=$(printf "%02d" $h):$(printf "%02d" $m):$(printf "%02d" $s)

  echo -e -n "Waiting $time_elapsed hours for Operations Manager instance $OPSMAN_HOST to become available.\r"
done

om \
  --target https://$OPSMAN_HOST \
  --skip-ssl-validation \
  configure-authentication \
  --username "$OPSMAN_USERNAME" \
  --password "$OPSMAN_PASSWORD" \
  --decryption-passphrase "${OPSMAN_DECRYPTION_KEY:-$OPSMAN_PASSWORD}"
