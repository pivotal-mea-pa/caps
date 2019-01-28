#
# jq -n \
#   --arg iaas "google" \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "deploy-service-broker": {
  },
  "destroy-broker": {
  }
}
|
# Merge in additonal IaaS specific configuration
if $iaas == "aws" 
  or $iaas == "google" 
  or $iaas == "azure" then

  . * {
    "deploy-service-broker": {
      "internet_connected": $internet_connected
    },
    "destroy-broker": {
      "internet_connected": $internet_connected
    }
  }
else
  .
end
