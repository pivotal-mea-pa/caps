#
# jq -n \
#   --arg proxy_static_ips "" \
#   --arg credentials_hostname "" \
#   --arg alerts_email "" \
#   --arg syslog_address "" \
#   --argjson syslog_port null \
#   --arg syslog_protocol "tcp" \
#   "$(cat properties.jq)"
#

# MySQL Configuration
{
  ".properties.optional_protections.enable.recipient_email": {
    "value": $alerts_email
  },
  ".proxy.static_ips": {
    "value": $proxy_static_ips
  },
  ".cf-mysql-broker.bind_hostname": {
    "value": $credentials_hostname
  }
}

# Syslog configuration
+
if $syslog_address != "" then
{
    ".properties.syslog": {
      "value": "enabled"
    },
    ".properties.syslog.enabled.address": {
      "value": $syslog_address
    },
    ".properties.syslog.enabled.port": {
      "value": $syslog_port
    },
    ".properties.syslog.enabled.protocol": {
      "value": $syslog_protocol
    }
}
else
{
  ".properties.syslog": {
    "value": "disabled"
  }
}
end
