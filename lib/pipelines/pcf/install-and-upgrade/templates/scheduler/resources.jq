#
# jq -n \
#   --arg iaas "google" \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "create-uaa-client": {
  },
  "deploy-scheduler": {
  },
  "register-broker": {
  },
  "publicize-scheduler": {
  },
  "test-scheduler": {
  },
  "destroy-scheduler": {
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
    "deploy-scheduler": {
      "internet_connected": $internet_connected
    },
    "register-broker": {
      "internet_connected": $internet_connected
    },
    "publicize-scheduler": {
      "internet_connected": $internet_connected
    },
    "test-scheduler": {
      "internet_connected": $internet_connected
    },
    "destroy-scheduler": {
      "internet_connected": $internet_connected
    }
  }
else
  .
end
