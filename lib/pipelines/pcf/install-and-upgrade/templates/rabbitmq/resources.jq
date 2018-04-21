#
# jq -n \
#   --argjson internet_connected false \
#   --arg rabbitmq_lb_name "" \
#   "$(cat resources.jq)"
#

{
  "rabbitmq-server": {
    "internet_connected": $internet_connected,
    "elb_names": ($rabbitmq_lb_name | split(","))
  },
  "rabbitmq-haproxy": {
    "internet_connected": $internet_connected
  },
  "rabbitmq-broker": {
    "internet_connected": $internet_connected
  },
  "broker-registrar": {
    "internet_connected": $internet_connected
  },
  "deregister-and-purge-instances": {
    "internet_connected": $internet_connected
  },
  "multitenant-smoke-tests": {
    "internet_connected": $internet_connected
  },
  "on-demand-broker": {
    "internet_connected": $internet_connected
  },
  "register-on-demand-service-broker": {
    "internet_connected": $internet_connected
  },
  "deregister-on-demand-service-broker": {
    "internet_connected": $internet_connected
  },
  "on-demand-broker-smoke-tests": {
    "internet_connected": $internet_connected
  },
  "delete-all-service-instances": {
    "internet_connected": $internet_connected
  },
  "upgrade-all-service-instances": {
    "internet_connected": $internet_connected
  }
}
|
if $rabbitmq_lb_name != "" then
  ."rabbitmq-haproxy" |= . + { "instances": 0 }
else
.
end
