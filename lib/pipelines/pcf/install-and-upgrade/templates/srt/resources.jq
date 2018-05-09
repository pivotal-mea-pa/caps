#
# jq -n \
#   --argjson internet_connected false \
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
    "internet_connected": $internet_connected,
    "elb_names": [ $pas_ssh_lb_name ]
  },
  "compute": {
    "instances": $num_diego_cells,
    "internet_connected": $internet_connected
  },
  "backup-prepare": {
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
    "instances": 0, 
    "internet_connected": $internet_connected
  },
}
