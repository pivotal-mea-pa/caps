#
# jq -n \
#   --arg iaas "google" \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "deploy-pcf-event-alerts": {
  },
  "destroy-pcf-event-alerts": {
  }
}
|
# Merge in additonal IaaS specific configuration
if $iaas == "aws" 
  or $iaas == "google" 
  or $iaas == "azure" then

  . * {
    "deploy-pcf-event-alerts": {
      "internet_connected": $internet_connected
    },
    "destroy-pcf-event-alerts": {
      "internet_connected": $internet_connected
    }
  }
else
  .
end
