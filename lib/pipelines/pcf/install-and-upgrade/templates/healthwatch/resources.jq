#
# jq -n \
#   --arg iaas "google" \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "mysql": {
  },
  "redis": {
  },
  "healthwatch-forwarder": {
  }
}
|
# Merge in additonal IaaS specific configuration
if $iaas == "aws" 
  or $iaas == "google" 
  or $iaas == "azure" then

  . * {
    "mysql": {
      "internet_connected": $internet_connected
    },
    "redis": {
      "internet_connected": $internet_connected
    },
    "healthwatch-forwarder": {
      "internet_connected": $internet_connected
    }
  }
else
  .
end
