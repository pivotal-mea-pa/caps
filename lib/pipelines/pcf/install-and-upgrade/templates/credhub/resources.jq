#
# jq -n \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "deploy-all": {
    "internet_connected": $internet_connected
  },
  "delete-all": {
    "internet_connected": $internet_connected
  }
}
