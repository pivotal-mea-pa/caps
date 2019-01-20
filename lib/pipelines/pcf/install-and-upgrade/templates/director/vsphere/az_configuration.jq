#
# jq -n \
#   --argjson availability_zone_config '{}' \
#   --argjson curr_az_configuration '{}' \
#   "$(cat az_configuration.jq)"
#

$availability_zone_config | .azs

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