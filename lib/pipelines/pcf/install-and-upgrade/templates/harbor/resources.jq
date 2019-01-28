#
# jq -n \
#   --arg iaas "google" \
#   --argjson internet_connected false \
#   --arg harbor_lb_name "tcp:pcf-poc1-pcf-harbor" \
#   "$(cat resources.jq)"
#

{
  "harbor-app": {
  },
  "smoke-testing": {
  }
}
|
# Merge in additonal IaaS specific configuration
if $iaas == "aws" 
  or $iaas == "google" 
  or $iaas == "azure" then

  . * {
    "harbor-app": {
      "internet_connected": $internet_connected,
      "elb_names": ($harbor_lb_name | split(","))
    },
    "smoke-testing": {
      "internet_connected": $internet_connected
    }
  }
else
  .
end
