#
# jq -n \
#   --argjson enable_global_access_to_plans true \
#   "$(cat properties.jq)"
#

{
  # Service Access
  ".properties.credhub_broker_enable_global_access_to_plans": {
    "value": $enable_global_access_to_plans
  }
}
