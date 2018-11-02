#
# jq -n \
#   --arg network_name "pas" \
#   --arg singleton_availability_zone "europe-west1-b" \
#   --arg availability_zones "$AVAILABILITY_ZONES" \
#   "$(cat network.jq)"
#

{
  "network": {
    "name": $network_name,
  },
  "singleton_availability_zone": {
    "name": $singleton_availability_zone
  },
  "other_availability_zones": ($availability_zones | split(",") | map({name: .}))
}
