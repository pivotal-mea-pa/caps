#
# jq -n \
#   --argjson internet_connected false \
#   --arg mysql_proxy_lb_name "" \
#   "$(cat resources.jq)"
#

{
  "mysql": {
    "internet_connected": $internet_connected
  },
  "backup-prepare": {
    "internet_connected": $internet_connected
  },
  "proxy": {
    "internet_connected": $internet_connected,
    "elb_names": ($mysql_proxy_lb_name | split(","))
  },
  "monitoring": {
    "internet_connected": $internet_connected
  },
  "cf-mysql-broker": {
    "internet_connected": $internet_connected
  },
  "broker-registrar": {
    "internet_connected": $internet_connected
  },
  "deregister-and-purge-instances": {
    "internet_connected": $internet_connected
  },
  "rejoin-unsafe": {
    "internet_connected": $internet_connected
  },
  "smoke-tests": {
    "internet_connected": $internet_connected
  },
  "bootstrap": {
    "internet_connected": $internet_connected
  }
}
