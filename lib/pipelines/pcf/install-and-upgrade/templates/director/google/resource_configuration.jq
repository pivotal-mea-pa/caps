#
# jq -n \
#   --argjson internet_connected false \
#   "$(cat resource_configuration.jq)"
#

{
  "director": {
    "internet_connected": $internet_connected,
    "persistent_disk": {
      "size_mb": "153600"
    },
  },
  "compilation": {
    "internet_connected": $internet_connected
  }
}
