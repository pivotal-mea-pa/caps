#
# jq -n \
#   --arg iaas "google" \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "deploy-service-broker": {
  },
  "register-service-broker": {
  },
  "run-smoke-tests": {
  },
  "destroy-service-broker": {
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
    "register-service-broker": {
      "internet_connected": $internet_connected
    },
    "run-smoke-tests": {
      "internet_connected": $internet_connected
    },
    "destroy-service-broker": {
      "internet_connected": $internet_connected
    }
  }
else
  .
end
