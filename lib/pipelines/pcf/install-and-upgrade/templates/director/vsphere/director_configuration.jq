#
# jq -n \
#   --arg ntp_servers "0.pool.ntp.org,1.pool.ntp.org" \
#   --argjson resurrector_enabled true \
#   --argjson post_deploy_enabled false \
#   --argjson retry_bosh_deploys true \
#   "$(cat director_config.jq)"
#

{
  "ntp_servers_string": $ntp_servers,
  "resurrector_enabled": $resurrector_enabled,
  "post_deploy_enabled": $post_deploy_enabled,
  "retry_bosh_deploys": $retry_bosh_deploys,
  "database_type": "internal",
  "blobstore_type": "local"
}
