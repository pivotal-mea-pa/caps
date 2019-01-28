#
# jq -n \
#   --arg iaas "google" \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "deploy-all": {
  },
  "delete-all": {
  }
}
|
# Merge in additonal IaaS specific configuration
if $iaas == "aws" 
  or $iaas == "google" 
  or $iaas == "azure" then

  . * {
    "deploy-all": {
      "internet_connected": $internet_connected
    },
    "delete-all": {
      "internet_connected": $internet_connected
    }
  }
else
  .
end
