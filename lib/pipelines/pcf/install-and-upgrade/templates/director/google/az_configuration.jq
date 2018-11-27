#
# jq -n \
#   --arg availability_zones "$AVAILABILITY_ZONES" \
#   --argjson curr_az_configuration '{}' \
#   "$(cat az_configuration.jq)"
#

($availability_zones | split(",") | map({name: .}))

|

[
  foreach .[] as $az (
    .; 
    [] | $az + {
      "guid": (
        (
          $curr_az_configuration 
            | .[] 
            | select(.name == ($az | .name)) 
            | .guid
        ) // null
      ),
    }
  )
]