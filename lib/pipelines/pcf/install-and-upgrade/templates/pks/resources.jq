#
# JSON Arguments:
#
#   internet_connected:   true | false
#   control_lb_names:     [ array of strings ]
#   router_lb_names:      [ array of strings ]
#   tcp_router_lb_names:  [ array of strings ]
#
# jq -n \
#   --argjson internet_connected false \
#   --arg pks_api_lb_name "tcp:pcf-poc1-pcf-pks-api" \
#   "$(cat resources.jq)"
#

{
  "pivotal-container-service": {
    # i.e. TCP load balancer for applications
    "internet_connected": $internet_connected,
    "elb_names": ($pks_api_lb_name | split(","))
  }
}
