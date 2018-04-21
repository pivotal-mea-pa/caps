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
  "register-broker": {
    "internet_connected": $internet_connected
  },
  "upgrade-all-service-instances": {
    "internet_connected": $internet_connected
  },
  "delete-all-service-instances-and-deregister-broker": {
    "internet_connected": $internet_connected
  },
  "on-demand-broker-smoke-tests": {
    "internet_connected": $internet_connected
  },

  # Shared Redis and Broker
  "cf-redis-broker": {
    "internet_connected": $internet_connected
  },
  "dedicated-node": {
    "internet_connected": $internet_connected
  },
  "broker-registrar": {
    "internet_connected": $internet_connected
  },
  "broker-deregistrar": {
    "internet_connected": $internet_connected
  },
  "smoke-tests": {
    "internet_connected": $internet_connected
  }
}
