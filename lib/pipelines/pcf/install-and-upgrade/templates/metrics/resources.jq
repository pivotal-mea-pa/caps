#
# jq -n \
#   --arg iaas "google" \
#   --argjson internet_connected false \
#   "$(cat resources.jq)"
#

{
  "elasticsearch_master": {
  },
  "elasticsearch_data": {
  },
  "redis": {
  },
  "mysql": {
  },
  "delete-metrics-1-3-space": {
  },
  "delete-metrics-1-4-space": {
  },
  "push-apps": {
  },
  "migrate-data-to-1-4": {
  },
  "smoke-tests": {
  }
}
|
# Merge in additonal IaaS specific configuration
if $iaas == "aws" 
  or $iaas == "google" 
  or $iaas == "azure" then

  . * {
    "elasticsearch_master": {
      "internet_connected": $internet_connected
    },
    "elasticsearch_data": {
      "internet_connected": $internet_connected
    },
    "redis": {
      "internet_connected": $internet_connected
    },
    "mysql": {
      "internet_connected": $internet_connected
    },
    "delete-metrics-1-3-space": {
      "internet_connected": $internet_connected
    },
    "delete-metrics-1-4-space": {
      "internet_connected": $internet_connected
    },
    "push-apps": {
      "internet_connected": $internet_connected
    },
    "migrate-data-to-1-4": {
      "internet_connected": $internet_connected
    },
    "smoke-tests": {
      "internet_connected": $internet_connected
    }
  }
else
  .
end
