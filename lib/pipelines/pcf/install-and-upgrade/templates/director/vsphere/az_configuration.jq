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
    .; [] 
    |
    # VSphere AZ's that have been configured
    # cannot be reconfigured once vms have been
    # deployed to it, even if values are the same
    # So simply ignore such AZs.
    if isempty(
      $curr_az_configuration 
        | .[] 
        | select(.name == ($az | .name)) 
        | .guid
    ) then
      $az
    else
      empty
    end
  )
]