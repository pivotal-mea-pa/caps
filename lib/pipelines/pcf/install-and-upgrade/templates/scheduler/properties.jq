#
# jq -n \
#   --argjson enable_outbound_http_calls true \
#   --arg ds_type "service_broker" \
#   --arg ds_service_broker_name "p.mysql" \
#   --arg ds_service_broker_plan "db-small" \
#   --arg ds_external_connection_string "" \
#   --argjson secure_credentials false \
#   "$(cat properties.jq)"
#

{
  # Scheduler configuration
  ".deploy-scheduler.enable_calls": {
    "value": $enable_outbound_http_calls
  }
}

# Configure Database Source
+
if $ds_type == "external" then
{
  ".properties.database_source.external.url": {
    "value": $ds_external_connection_string
  }
}
else
{
  ".properties.database_source": {
    "value": "service_broker"
  },
  ".properties.database_source.service_broker.name": {
    "value": $ds_service_broker_name
  },
  ".properties.database_source.service_broker.plan_name": {
    "value": $ds_service_broker_plan
  }
}
end