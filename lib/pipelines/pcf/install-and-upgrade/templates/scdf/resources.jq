#
# jq -n \
#   --arg iaas "google" \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "create-uaa-client": {
  },
  "run-tests": {
  },
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
    "create-uaa-client": {
      "internet_connected": $internet_connected
    },
    "run-tests": {
      "internet_connected": $internet_connected
    },
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
