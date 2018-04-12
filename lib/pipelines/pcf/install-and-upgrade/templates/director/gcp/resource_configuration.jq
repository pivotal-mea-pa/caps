#
# jq -n \
#   --argjson internet_connected false \
#   "$(cat resource_configuration.jq)"
#

{
  "director": {
    "internet_connected": $internet_connected
  },
  "compilation": {
    "internet_connected": $internet_connected
  }
}
