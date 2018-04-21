#
# jq -n \
#   --argjson internet_connected false \
#   --arg mysql_proxy_lb_name "" \
#   "$(cat resources.jq)"
#

{
  "deploy-service-broker": {
    "internet_connected": $internet_connected
  },
  "register-service-broker": {
    "internet_connected": $internet_connected
  },
  "run-smoke-tests": {
    "internet_connected": $internet_connected
  },
  "destroy-service-broker": {
    "internet_connected": $internet_connected
  }
}
