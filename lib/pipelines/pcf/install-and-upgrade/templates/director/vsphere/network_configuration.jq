#
# jq -n \
#   --argjson icmp_checks_enabled false \
#   --argjson pcf_networks '{}' \
#   --argjson curr_network_configuration '{"networks":[]}' \
#   "$(cat network_configuration.jq)"
#

{
  "icmp_checks_enabled": $icmp_checks_enabled,

  "networks": [ $pcf_networks | .pcf_networks
    #
    # Build list of network names by creating
    # a unique list of names reduced from the
    # pcf_networks.pcf_network list.
    #
    | 
    reduce (.[]) as $n (
      []; . + [ $n.network_name ]
    ) 
    | 
    unique
    #
    # Build list of networks for each of the above
    #
    |
    foreach (.[]) as $n (
      .; []
      | 
      {
        #
        # If network has already been configured by
        # Ops Manager then insert its GUID
        #
        "guid": (
          ( $curr_network_configuration 
            | .networks[] 
            | select(.name == $n) 
            | .guid
          ) // null
        ),
        "name": $n,
        "service_network": (
          $pcf_networks 
          | .pcf_networks[] 
          | select(.network_name == $n) 
          | (.is_service_network == "1")
        ),
        #
        # Build list of subnets
        #
        "subnets": ( 
          [
            $pcf_networks 
            | .pcf_networks[] 
            | select(.network_name == $n)
          ]
          |
          reduce (.[]) as $n (
            []; . + [ {              
              "iaas_identifier": $n.iaas_identifier,
              "cidr": $n.cidr,
              "gateway": $n.gateway,
              "reserved_ip_ranges": $n.reserved_ip_ranges,
              "dns": $n.dns,
              "availability_zone_names": ($n.availability_zone_names | split(","))
            } ]
          )
        )
      }
    )
  ]
}
