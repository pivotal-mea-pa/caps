#
# jq -n \
#   --arg director_persistent_disk_size '51200' \
#   "$(cat resource_configuration.jq)"
#

{
  "director": {
    "persistent_disk": {
      "size_mb": $director_persistent_disk_size
    }
  }
}
