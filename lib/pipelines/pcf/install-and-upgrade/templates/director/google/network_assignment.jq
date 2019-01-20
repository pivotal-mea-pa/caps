#
# jq -n \
#   --arg availability_zones "" \
#   --arg network "infrastructure" \
#   "$(cat network_assignment.jq)"
#
{
  "network": {
    "name": $network
  },
  "singleton_availability_zone": {
    "name": ($availability_zones | split(",") | .[0])
  }
}
