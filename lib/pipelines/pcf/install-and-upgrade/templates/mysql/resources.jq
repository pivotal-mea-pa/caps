#
# jq -n \
#   --arg iaas "google" \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "dedicated-mysql-broker": {
    "internet_connected": $internet_connected
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
