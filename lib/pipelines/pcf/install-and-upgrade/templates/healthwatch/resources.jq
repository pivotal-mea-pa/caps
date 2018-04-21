#
# jq -n \
#   --argjson num_mysql_instances 3 \
#   --argjson num_proxy_instances 2 \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "mysql": {
    "internet_connected": $internet_connected,
    "instances": $num_mysql_instances
  },
  "proxy": {
    "internet_connected": $internet_connected,
    "instances": $num_proxy_instances
  },
  "healthwatch-forwarder": {
    "internet_connected": $internet_connected
  },
  "rejoin-unsafe": {
    "internet_connected": $internet_connected
  },
  "bootstrap": {
    "internet_connected": $internet_connected
  }
}
