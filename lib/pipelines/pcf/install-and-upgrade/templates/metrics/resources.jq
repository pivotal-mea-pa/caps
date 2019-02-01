#
# jq -n \
#   --arg iaas "google" \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "redis": {
  },
  "mysql": {
  },
  "postgres": {
  },
  "errand-runner": {
  }
}
|
# Merge in additonal IaaS specific configuration
if $iaas == "aws" 
  or $iaas == "google" 
  or $iaas == "azure" then

  . * {
    "redis": {
      "internet_connected": $internet_connected
    },
    "mysql": {
      "internet_connected": $internet_connected
    },
    "postgres": {
      "internet_connected": $internet_connected
    },
    "errand-runner": {
      "internet_connected": $internet_connected
    }
  }
else
  .
end
