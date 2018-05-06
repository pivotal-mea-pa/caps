#
# jq -n \
#   --argjson internet_connected false \
#   --arg harbor_lb_name "tcp:pcf-poc1-pcf-harbor" \
#   "$(cat resources.jq)"
#

{
  "harbor-app": {
    "internet_connected": $internet_connected,
    "elb_names": ($harbor_lb_name | split(","))
  },
  "smoke-testing": {
    "internet_connected": $internet_connected
  }
}
