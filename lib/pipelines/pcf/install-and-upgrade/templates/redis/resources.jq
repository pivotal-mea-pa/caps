#
# jq -n \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  # On Demand Broker
  "redis-on-demand-broker": {
    "internet_connected": $internet_connected
  },
  "cf-redis-broke": {
    "internet_connected": $internet_connected
  },
  "dedicated-node": {
    "internet_connected": $internet_connected
  }
}
