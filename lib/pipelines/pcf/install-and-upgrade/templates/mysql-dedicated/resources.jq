#
# jq -n \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "dedicated-mysql-broker": {
    "internet_connected": $internet_connected
  },
  "register-broker": {
    "internet_connected": $internet_connected
  },
  "smoke-tests": {
    "internet_connected": $internet_connected
  },
  "delete-all-service-instances-and-deregister-broker": {
    "internet_connected": $internet_connected
  },
  "upgrade-all-service-instances": {
    "internet_connected": $internet_connected
  },
  "orphan-deployments": {
    "internet_connected": $internet_connected
  }
}
