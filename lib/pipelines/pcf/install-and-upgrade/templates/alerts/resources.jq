#
# jq -n \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "mysql": {
    "internet_connected": $internet_connected
  },
  "redis": {
    "internet_connected": $internet_connected
  },
  "healthwatch-forwarder": {
    "internet_connected": $internet_connected
  }
}
