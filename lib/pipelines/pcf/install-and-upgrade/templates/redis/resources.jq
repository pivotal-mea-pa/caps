#
# jq -n \
#   --arg iaas "google" \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "redis-on-demand-broker": {
  },
  "cf-redis-broker": {
  }
}
|
# Merge in additonal IaaS specific configuration
if $iaas == "aws" 
  or $iaas == "google" 
  or $iaas == "azure" then

  . * {
    "redis-on-demand-broker": {
      "internet_connected": $internet_connected
    },
    "cf-redis-broker": {
      "internet_connected": $internet_connected
    }
  }
else
  .
end
