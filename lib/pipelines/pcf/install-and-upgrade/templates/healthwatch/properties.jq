#
# jq -n \
#   --arg foundation_name "pcf-poc-1" \
#   --arg opsman_url "https://opsman.pas.pcfenv1.pocs.pcfs.io" \
#   --arg availability_zones "europe-west1-b,europe-west1-c,europe-west1-d" \
#   "$(cat properties.jq)"
#

# Configure Healthwatch
{
  ".healthwatch-forwarder.foundation_name": {
    "value": $foundation_name
  },
  ".healthwatch-forwarder.health_check_az": {
    "value": ($availability_zones | split(",") | .[0])
  }
}
+
if "opsman_url" != "" then
{
    ".properties.opsman.enable.url": {
      "value": $opsman_url
    }
}
else
{
  ".properties.opsman": {
    "value": "disable"
  }
}
end
