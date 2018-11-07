#
# jq -n \
#   --arg db_event_alerts_type "internal" \
#   --arg opsman_url "" \
#   --arg boshtasks_uaa_client "" \
#   --arg boshtasks_uaa_client_secret "" \
#   --arg availability_zones "$AVAILABILITY_ZONES" \
#   "$(cat properties.jq)"
#

#
# Database
#
if $db_event_alerts_type == "external" then
{
  ".properties.uaa_database": { "value": $db_uaa_type },
  ".properties.uaa_database.external.host": { "value": $db_host },
  ".properties.uaa_database.external.port": { "value": $db_port },
  ".properties.uaa_database.external.uaa_username": { "value": $db_uaa_username },
  ".properties.uaa_database.external.uaa_password": { "value": { "secret": $db_uaa_password } },
}
else
{
  ".properties.uaa_database": { "value": $db_event_alerts_type },
}

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
if $opsman_url != "" then
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
if $boshtasks_uaa_client != "" then
{
  ".properties.boshtasks": {
    "value": "enable"
  },
  ".properties.boshtasks.enable.bosh_taskcheck_username": {
    "value": $boshtasks_uaa_client
  },
  ".properties.boshtasks.enable.bosh_taskcheck_password": {
    "value": $boshtasks_uaa_client_secret
  }
}
else
{
  ".properties.boshtasks": {
      "value": "disable"
  }
}
end
