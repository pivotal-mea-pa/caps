#
# jq -n \
#   --arg network_name "ert" \
#   --arg singleton_availability_zone "europe-west1-b" \
#   --arg other_availability_zones "europe-west1-b,europe-west1-c,europe-west1-d" \
#   "$(cat network.jq)"
#

{
  "network": {
    "name": $network_name,
  },
  "singleton_availability_zone": {
    "name": $singleton_availability_zone
  },
  "other_availability_zones": ($other_availability_zones | split(",") | map({name: .}))
}
