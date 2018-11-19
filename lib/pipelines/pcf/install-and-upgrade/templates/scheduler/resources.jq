#
# jq -n \
#   --argjson internet_connected false \
#   --arg mysql_proxy_lb_name "" \
#   "$(cat resources.jq)"
#

{
  "create-uaa-client": {
    "internet_connected": $internet_connected
  },
  "deploy-scheduler": {
    "internet_connected": $internet_connected
  },
  "register-broker": {
    "internet_connected": $internet_connected
  },
  "publicize-scheduler": {
    "internet_connected": $internet_connected
  },
  "test-scheduler": {
    "internet_connected": $internet_connected
  },
  "destroy-scheduler": {
    "internet_connected": $internet_connected
  }
}
