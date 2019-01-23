#
# jq -n \
#   --arg iaas "google" \
#   --argjson internet_connected false \
#   --argjson num_pks_service_instances 1 \
#   --arg pks_lb_name "tcp:pcf-poc1-pcf-pks" \
#   "$(cat resources.jq)"
#

{
  "pivotal-container-service": {
    "instances": $num_pks_service_instances
  }
}
|
# Merge in additonal IaaS specific configuration
if $iaas == "aws" 
  or $iaas == "google" 
  or $iaas == "azure" then

  . * {
    "pivotal-container-service": {
      # i.e. TCP load balancer for applications
      "internet_connected": $internet_connected,
      "elb_names": ($pks_lb_name | split(","))
    }
  }
else
  .
end
