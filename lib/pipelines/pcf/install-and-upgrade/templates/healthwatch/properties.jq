#
# jq -n \
#   --arg foundation_name "pcf-poc-1" \
#   --arg opsman_url "" \
#   --arg uaa_client "" \
#   --arg uaa_client_secret "" \
#   --arg availability_zones "$AVAILABILITY_ZONES" \
#   "$(cat properties.jq)"
#

# Configure Healthwatch
{
  ".healthwatch-forwarder.foundation_name": {
    "value": $foundation_name
  },
  ".healthwatch-forwarder.health_check_az": {
    "value": ($availability_zones | split(",") | .[0])
  }
}
+
if "opsman_url" != "" then
{
    ".properties.opsman.enable.url": {
      "value": $opsman_url
    }
}
else
{
  ".properties.opsman": {
    "value": "disable"
  }
}
end
+
if "uaa_client" != "" then
{
    ".properties.boshtasks": {
      "value": "enable"
    },
    ".properties.boshtasks.enable.bosh_taskcheck_username": {
      "value": $uaa_client
    },
    ".properties.boshtasks.enable.bosh_taskcheck_password": {
      "value": $uaa_client_secret
    }
}
else
{

}
end