#
# jq -n \
#   --arg config_server_access "global" \
#   --arg java_buildpack "java_buildpack_offline" \
#   --argjson status_change_timeout_minutes 30 \
#   "$(cat properties.jq)"
#

{
    ".properties.config_server_access": {
      "value": $config_server_access
    },
    ".properties.java_buildpack": {
      "value": $java_buildpack
    },
    ".properties.status_change_timeout_minutes": {
      "value": $status_change_timeout_minutes
    }
}
