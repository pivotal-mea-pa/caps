#
# jq -n \
#   --arg director_persistent_disk_size '51200' \
#   --argjson internet_connected false \
#   "$(cat resource_configuration.jq)"
#

{
  "director": {
    "internet_connected": $internet_connected,
    "persistent_disk": {
      "size_mb": $director_persistent_disk_size
    }
  },
  "compilation": {
    "internet_connected": $internet_connected
  }
}
