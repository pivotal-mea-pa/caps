#!/bin/bash

source ~/scripts/opsman-func.sh
source ~/scripts/bosh-func.sh
root=$PWD

[[ -n "$TRACE" ]] && set -x
set -eo pipefail

# Retrieve bosh credentials from Ops Manager API and set BOSH envrionment

if [[ -n "$OPSMAN_USERNAME" ]]; then
  opsman::login $OPSMAN_HOST $OPSMAN_USERNAME $OPSMAN_PASSWORD ''
elif [[ -n "$OPSMAN_CLIENT_ID" ]]; then
  opsman::login_client $OPSMAN_HOST $OPSMAN_CLIENT_ID $OPSMAN_CLIENT_SECRET ''
else
  echo "ERROR! Pivotal Operations Manager credentials were not provided."
  exit 1
fi

export BOSH_ENVIRONMENT=$(opsman::get_director_ip)
export BOSH_CA_CERT=$(opsman::download_bosh_ca_cert)
export BOSH_CLIENT='ops_manager'
export BOSH_CLIENT_SECRET=$(opsman::get_director_client_secret ops_manager)

bosh::login_client "$BOSH_CA_CERT" "$BOSH_ENVIRONMENT" "$BOSH_CLIENT" "$BOSH_CLIENT_SECRET"

pushd automation/lib/pipelines/pcf/install-and-upgrade/tasks/upload-patcher/patch-deployment-release/

latest_release_version=$($bosh releases | awk '/^patch-deployment/{ print $2 }' | head -1)
if [[ -n $latest_release_version ]]; then
  latest_release_info=$($bosh inspect-release patch-deployment/$latest_release_version --json | jq '[ .Tables[0].Rows[].job ]')

  release_version=${latest_release_version%\**}
  version=${release_version%.*}
  build_number=${release_version##*.}
  new_version=${version}.$(($build_number+1))
else
  latest_release_info='[]'
  new_version=0.0.1
fi

release_build_info=$($bosh create-release --json --force --version=$new_version | jq '[ .Tables[1].Rows[].job ]')

new_jobs=$(jq -n \
  --argjson latest "$latest_release_info" \
  --argjson build "$release_build_info" \
  '$build - $latest | length')

if [[ $new_jobs -ne 0 ]]; then
  $bosh upload-release --non-interactive
fi

popd
