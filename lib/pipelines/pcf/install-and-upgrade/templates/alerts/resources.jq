#
# jq -n \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "deploy-pcf-event-alerts": {
    "internet_connected": $internet_connected
  },
  "destroy-pcf-event-alerts": {
    "internet_connected": $internet_connected
  }
}
