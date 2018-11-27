#
# jq -n \
#   --argjson internet_connected false \
#   --arg rabbitmq_lb_name "" \
#   "$(cat resources.jq)"
#

{
  "rabbitmq-broker": {
    "internet_connected": $internet_connected
  },
  "rabbitmq-haproxy": {
    "internet_connected": $internet_connected
  },
  "rabbitmq-server": {
    "internet_connected": $internet_connected,
    "elb_names": ($rabbitmq_lb_name | split(","))
  },
  "on-demand-broker": {
    "internet_connected": $internet_connected
  },
}
|
if $rabbitmq_lb_name != "" then
  ."rabbitmq-haproxy" |= . + { "instances": 0 }
else
.
end
