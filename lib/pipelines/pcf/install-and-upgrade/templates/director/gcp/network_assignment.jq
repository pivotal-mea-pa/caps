  jq -n \
    --arg availability_zones "$availability_zones" \
    --arg network "infrastructure" \
    '
    {
      "singleton_availability_zone": ($availability_zones | split(",") | .[0]),
      "network": $network
    }'