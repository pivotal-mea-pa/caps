#
# jq -n \
#   --argjson availability_zones '{}' \
#   --argjson curr_az_configuration '{}' \
#   "$(cat az_configuration.jq)"
#

$availability_zones | .azs

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