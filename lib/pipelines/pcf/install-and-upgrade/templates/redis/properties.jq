#
# jq -n \
#   --arg redis_shared_maxmemory "512MB" \
#   --argjson redis_shared_instance_limit 5 \
#   --argjson redis_on_demand_instance_limit 20 \
#   --arg small_plan_az "europe-west1-b" \
#   --argjson small_plan_instance_limit 20 \
#   --arg medium_plan_az "europe-west1-c" \
#   --argjson medium_plan_instance_limit 20 \
#   --arg large_plan_az "europe-west1-d" \
#   --argjson large_plan_instance_limit 0 \
#   --arg syslog_address "" \
#   --argjson syslog_port null \
#   --arg syslog_transport "tcp" \
#   --arg syslog_format "rfc5424" \
#   --argjson tls_syslog_permitted_peer null \
#   --arg tls_syslog_ca_cert "" \
#   "$(cat properties.jq)"
#

{
  ".cf-redis-broker.redis_maxmemory": { "value": $redis_shared_maxmemory },
  ".cf-redis-broker.service_instance_limit": { "value": $redis_shared_instance_limit },
  ".redis-on-demand-broker.service_instance_limit": { "value": $redis_on_demand_instance_limit },
}

# Configure plans
+
if $small_plan_instance_limit > 0 then
{
  ".properties.small_plan_selector": { "value": "Plan Active" },
  ".properties.small_plan_selector.active.cf_service_access": { "value": "enable" },
  ".properties.small_plan_selector.active.az_single_select": { "value": $small_plan_az },
  ".properties.small_plan_selector.active.instance_limit": { "value": $small_plan_instance_limit }
}
else
{ 
  ".properties.small_plan_selector": { "value": "Plan Inactive" },
}
end
+
if $medium_plan_instance_limit > 0 then
{
  ".properties.medium_plan_selector": { "value": "Plan Active" },
  ".properties.medium_plan_selector.active.cf_service_access": { "value": "enable" },
  ".properties.medium_plan_selector.active.az_single_select": { "value": $medium_plan_az },
  ".properties.medium_plan_selector.active.instance_limit": { "value": $medium_plan_instance_limit }
}
else
{ 
  ".properties.medium_plan_selector": { "value": "Plan Inactive" } 
}
end
+
if $large_plan_instance_limit > 0 then
{
  ".properties.large_plan_selector": { "value": "Plan Active" },
  ".properties.large_plan_selector.active.cf_service_access": { "value": "enable" },
  ".properties.large_plan_selector.active.az_single_select": { "value": $large_plan_az },
  ".properties.large_plan_selector.active.instance_limit": { "value": $large_plan_instance_limit }
}
else
{ 
  ".properties.large_plan_selector": { "value": "Plan Inactive" } 
}
end

# Configure syslog
+
if $tls_syslog_ca_cert != "" then
{
    ".properties.syslog_selector.active_with_tls.syslog_address": { "value": $syslog_address },
    ".properties.syslog_selector.active_with_tls.syslog_port": { "value": $syslog_port },
    ".properties.syslog_selector.active_with_tls.syslog_transport": { "value": $syslog_transport },
    ".properties.syslog_selector.active_with_tls.syslog_format": { "value": $syslog_format },
    ".properties.syslog_selector.active_with_tls.syslog_permitted_peer": { "value": $tls_syslog_permitted_peer },
    ".properties.syslog_selector.active_with_tls.syslog_ca_cert": { "value": $tls_syslog_ca_cert }
}
else 

  if $syslog_address != "" then
  {
    ".properties.syslog_selector.active.syslog_address": { "value": $syslog_address },
    ".properties.syslog_selector.active.syslog_port": { "value": $syslog_port },
    ".properties.syslog_selector.active.syslog_transport": { "value": $syslog_transport },
    ".properties.syslog_selector.active.syslog_format": { "value": $syslog_format }
  }
  else
  {
    ".properties.syslog_selector": { "value": "No" } 
  }
  end

end