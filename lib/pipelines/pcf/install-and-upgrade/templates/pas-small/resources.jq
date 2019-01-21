#
# jq -n \
#   --arg iaas "google" \
#   --argjson internet_connected false \
#   --arg ha_proxy_static_ip "" \
#   --arg pas_http_lb_name "http:pcf-poc1-pcf-http-lb-backend" \
#   --arg pas_tcp_lb_name "tcp:pcf-poc1-pcf-cf-tcp-lb" \
#   --arg pas_ssh_lb_name "tcp:pcf-poc1-pcf-ssh-proxy" \
#   --arg pas_doppler_lb_name "tcp:pcf-poc1-pcf-wss-logs" \
#   --argjson num_diego_cells 1
#   "$(cat resources.jq)"
#

{
  "database": {
    "internet_connected": $internet_connected
  },
  "blobstore": {
    "internet_connected": $internet_connected
  },
  "control": {
    "internet_connected": $internet_connected
  },
  "compute": {
    "instances": $num_diego_cells,
    "internet_connected": $internet_connected
  },
  #
  # Removed from 2.2 -> 2.3
  #
  # "backup-prepare": {
  #   "internet_connected": $internet_connected
  # },
  "backup_restore": {
    "internet_connected": $internet_connected
  },
  "router": {
    "internet_connected": $internet_connected
  },
  "tcp_router": {
    "internet_connected": $internet_connected
  },
  "mysql_monitor": {
    "internet_connected": $internet_connected
  },
}
+
# Add HA Proxy if a static IP for the service
# has been configured
if $ha_proxy_static_ip != "" then
{
  "ha_proxy": {
    "instances": 1,
    "internet_connected": $internet_connected
  }
}
else
{
  "ha_proxy": {
    "instances": 0,
    "internet_connected": $internet_connected
  }
}
end
|
# Merge in additonal IaaS specific configuration
if $iaas == "aws" 
  or $iaas == "google" then

  . * {
    "control": {
      "elb_names": [ $pas_ssh_lb_name ]
    },
    "router": {
      "elb_names": [ $pas_http_lb_name, $pas_doppler_lb_name ]
    },
    "tcp_router": {
      "elb_names": [ $pas_tcp_lb_name ]
    },
  }
else
  .
end
