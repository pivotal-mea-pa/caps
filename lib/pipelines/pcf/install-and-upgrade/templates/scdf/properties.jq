#
# jq -n \
#   --arg db_service_name "p.mysql" \
#   --arg db_service_plan "db-small" \
#   --arg dataflow_db_service "p.mysql" \
#   --arg dataflow_db_plan "db-small" \
#   --arg dataflow_redis_service "p.redis" \
#   --arg dataflow_redis_plan "cache-small" \
#   --arg dataflow_messaging_service "p.rabbitmq" \
#   --arg dataflow_messaging_plan "single-node" \
#   --arg skipper_db_service "p.mysql" \
#   --arg skipper_db_plan "db-small" \
#   --argjson enable_global_access_to_plans true \
#   "$(cat properties.jq)"
#

{
  # Service Broker
  ".properties.db_service_name": { 
    "value": $db_service_name
  },
  ".properties.db_service_plan": {
    "value": $db_service_plan
  },
  # Data Flow Server
  ".properties.dataflow_db_service": {
    "value": $dataflow_db_service
  },
  ".properties.dataflow_db_plan": {
    "value": $dataflow_db_plan
  },
  ".properties.dataflow_messaging_service": {
    "value": $dataflow_messaging_service
  },
  ".properties.dataflow_messaging_plan": {
    "value": $dataflow_messaging_plan
  },
  # Skipper
  ".properties.skipper_db_service": {
    "value": $skipper_db_service
  },
  ".properties.skipper_db_plan": {
    "value": $skipper_db_plan
  },
  # Service Access
  ".properties.p_dataflow_enable_global_access_to_plans": {
    "value": $enable_global_access_to_plans
  }
}
