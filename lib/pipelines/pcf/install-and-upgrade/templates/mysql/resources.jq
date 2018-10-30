#
# jq -n \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "dedicated-mysql-broker": {
    "internet_connected": $internet_connected
  }
}
