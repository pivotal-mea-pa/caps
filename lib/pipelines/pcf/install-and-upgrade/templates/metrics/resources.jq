#
# jq -n \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "elasticsearch_master": {
    "internet_connected": $internet_connected
  },
  "elasticsearch_data": {
    "internet_connected": $internet_connected
  },
  "redis": {
    "internet_connected": $internet_connected
  },
  "mysql": {
    "internet_connected": $internet_connected
  },
  "delete-metrics-1-3-space": {
    "internet_connected": $internet_connected
  },
  "delete-metrics-1-4-space": {
    "internet_connected": $internet_connected
  },
  "push-apps": {
    "internet_connected": $internet_connected
  },
  "migrate-data-to-1-4": {
    "internet_connected": $internet_connected
  },
  "smoke-tests": {
    "internet_connected": $internet_connected
  }
}
