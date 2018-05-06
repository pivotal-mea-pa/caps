#
# jq -n \
#   --argjson internet_connected false \
#   --arg mysql_proxy_lb_name "" \
#   "$(cat resources.jq)"
#

{
  "harbor-app": {
    "internet_connected": $internet_connected
  },
  "smoke-testing": {
    "internet_connected": $internet_connected
  }
}
