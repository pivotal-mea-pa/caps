#
# jq -n \
#   --arg availability_zones "europe-west1-b,europe-west1-c,europe-west1-d" \
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
