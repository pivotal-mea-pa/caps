#
# JSON Arguments:
#
#   network_name:                 name of service network defined in Director
#   service_network_name:         name of on-demand service network defined in Director
#   singleton_availability_zone:  availability zone to place singleton services in
#   other_availability_zones:     comma separated list of availability zones defined in Director
#
# jq -n \
#   --arg network_name "services-1" \
#   --arg service_network_name "dynamic-services-1" \
#   --arg singleton_availability_zone "europe-west1-b" \
#   --arg other_availability_zones "europe-west1-b,europe-west1-c,europe-west1-d" \
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
    "name": $singleton_availability_zone
  },
  "other_availability_zones": ($other_availability_zones | split(",") | map({name: .}))
}
