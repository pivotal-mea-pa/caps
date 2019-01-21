#
# jq -n \
#   --arg iaas "google" \
#   --argjson internet_connected false \
#   --arg ha_proxy_static_ip "" \
#   --arg pas_http_lb_name "http:pcf-poc1-pcf-http-lb-backend" \
#   --arg pas_tcp_lb_name "tcp:pcf-poc1-pcf-cf-tcp-lb" \
#   --arg pas_ssh_lb_name "tcp:pcf-poc1-pcf-ssh-proxy" \
#   --arg pas_doppler_lb_name "tcp:pcf-poc1-pcf-wss-logs" \
#   --arg num_control_instances "automatic"
#   --arg num_diego_cells "automatic"
#   --arg num_router_instances "automatic"
#   --arg num_tcp_router_instances "automatic"
#   --argjson run_mysql_monitor true
#   "$(cat resources.jq)"
#

{
  "database": {
    "instances": "automatic"
  },
  "blobstore": {
    "instances": "automatic"
  },
  "control": {
    "instances": $num_control_instances
  },
  "compute": {
    "instances": $num_diego_cells,
  },
  "backup_restore": {
    "instances": "automatic"
  },
  "router": {
    "instances": $num_router_instances
  },
  "tcp_router": {
    "instances": $num_tcp_router_instances
  }
}
+
# If mysql monitor should not be run then
# set the number of instances to 0
if $run_mysql_monitor then
  {
    "mysql_monitor": {
      "instances": "automatic"
    },
  }
else
  {
    "mysql_monitor": {
      "instances": "0"
    },
  }
end
+
# Add HA Proxy if a static IP for the service
# has been configured
if $ha_proxy_static_ip != "" then
  {
    "ha_proxy": {
      "instances": "1",
      "internet_connected": $internet_connected
    }
  }
else
  {
    "ha_proxy": {
      "instances": "0",
      "internet_connected": $internet_connected
    }
  }
end
|
# Merge in additonal IaaS specific configuration
if $iaas == "aws" 
  or $iaas == "google" then

  . * {
    "database": {
      "internet_connected": $internet_connected
    },
    "blobstore": {
      "internet_connected": $internet_connected
    },
    "control": {
      "internet_connected": $internet_connected,
      "elb_names": [ $pas_ssh_lb_name ]
    },
    "compute": {
      "internet_connected": $internet_connected
    },    
    "backup_restore": {
      "internet_connected": $internet_connected
    },
    "router": {
      "internet_connected": $internet_connected,
      "elb_names": [ $pas_http_lb_name, $pas_doppler_lb_name ]
    },
    "tcp_router": {
      "internet_connected": $internet_connected,
      "elb_names": [ $pas_tcp_lb_name ]
    },
    "mysql_monitor": {
      "internet_connected": $internet_connected
    },  
  }
else
  .
end
