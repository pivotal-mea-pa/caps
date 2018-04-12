#
# jq -n \
#   --arg availability_zones "europe-west1-b,europe-west1-c,europe-west1-d" \
#   "$(cat az_configuration.jq)"
#

($availability_zones | split(",") | map({name: .}))
