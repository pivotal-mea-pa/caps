#
# jq -n \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "deploy-service-broker": {
    "internet_connected": $internet_connected
  },
  "destroy-broker": {
    "internet_connected": $internet_connected
  }
}
