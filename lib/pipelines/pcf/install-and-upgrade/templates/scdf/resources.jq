#
# jq -n \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "create-uaa-client": {
    "internet_connected": $internet_connected
  },
  "run-tests": {
    "internet_connected": $internet_connected
  },
  "deploy-all": {
    "internet_connected": $internet_connected
  },
  "delete-all": {
    "internet_connected": $internet_connected
  }
}
