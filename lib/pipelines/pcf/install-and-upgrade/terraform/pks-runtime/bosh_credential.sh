#!/bin/bash

exec 2> >(tee bosh_credential.log 2>&1 >/dev/null)

set -eu

manifest=$(om "$@" curl --silent --path=/api/v0/deployed/director/manifest \
  | jq -r ".instance_groups[] | select(.name == \"bosh\")")

host=$(echo "$manifest" \
  | jq -r ".properties.director.address")

client_id="ops_manager"
client_secret=$(echo "$manifest" \
  | jq -r ".properties.uaa.clients.$client_id.secret")

ca_cert=$(om "$@" curl --silent --path /api/v0/certificate_authorities \
  | jq '.certificate_authorities[] | select(.issuer | match("Pivotal")) | .cert_pem')

echo "{\"host\":\"$host\",\"ca_cert\":$ca_cert,\"client_id\":\"$client_id\",\"client_secret\":\"$client_secret\"}"
