#
# jq -n \
#   --arg pcf_network_ntp "0.pool.ntp.org,1.pool.ntp.org" \
#   --argjson resurrector_enabled true \
#   --argjson post_deploy_enabled false \
#   --argjson retry_bosh_deploys true \
#   "$(cat director_config.jq)"
#

{
  "ntp_servers_string": $pcf_network_ntp,
  "resurrector_enabled": $resurrector_enabled,
  "post_deploy_enabled": $post_deploy_enabled,
  "retry_bosh_deploys": $retry_bosh_deploys,
  "database_type": "internal",
  "blobstore_type": "local"
}
