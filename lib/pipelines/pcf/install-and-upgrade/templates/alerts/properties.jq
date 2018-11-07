#
# jq -n \
#   --arg event_alerts_db_type "internal" \
#   --arg db_host "" \
#   --arg db_port "3306" \
#   --arg db_username "cf_db_user" \
#   --arg db_password "DbP@ssw0rd" \
#   --arg db_external_name "eventalerts" \
#   --arg db_internal_plan_name "db-small" \
#   --arg from_email_address "" \
#   --arg smtp_host "" \
#   --arg smtp_port "" \
#   --arg smtp_username "" \
#   --arg smtp_password "" \
#   "$(cat properties.jq)"
#

#
# Database
#
if $event_alerts_db_type == "external" then
{
  ".properties.mysql": { "value": "External DB" },
  ".properties.mysql.external.host": { "value": $db_host },
  ".properties.mysql.external.port": { "value": $db_port },
  ".properties.mysql.external.username": { "value": $db_username },
  ".properties.mysql.external.password": { "value": { "secret": $db_password } },
  ".properties.mysql.external.database": { "value": $db_external_name }
}
else
{
  ".properties.mysql": { "value": "MySQL Service" },
  ".properties.mysql.internal.plan_name": { "value": $db_internal_plan_name }
}
end

# Configure SMTP
+
if $from_email_address != "" and $smtp_host != "" then
{
  ".properties.smtp_selector": { "value": "Enabled" },
  ".properties.smtp_selector.enabled.smtp_from": { "value": $from_email_address },
  ".properties.smtp_selector.enabled.smtp_address": { "value": $smtp_host },
  ".properties.smtp_selector.enabled.smtp_port": { "value": $smtp_port },
  ".properties.smtp_selector.enabled.smtp_credentials": {
      "value": {
        "identity": $smtp_username,
        "password": $smtp_password
      }
    }
}
else
{
  ".properties.smtp_selector": { "value": "Disabled" },
}
end
