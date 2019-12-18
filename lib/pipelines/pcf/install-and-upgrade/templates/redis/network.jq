#
# jq -n \
#   --arg network_name "services" \
#   --arg service_network_name "dynamic-services" \
#   --arg singleton_availability_zone "europe-west1-b" \
#   --arg availability_zones "$AVAILABILITY_ZONES" \
#   "$(cat network.jq)"
#

{
  "network": {
    "name": $network_name,
  },
  "service_network": {
    "name": $service_network_name,
  },
  "singleton_availability_zone": {
    "name": "europe-west1-c",
    # "name": $singleton_availability_zone,
  },
  "other_availability_zones": ($availability_zones | split(",") | map({name: .}))
}
