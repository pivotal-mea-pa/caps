#
# jq -n \
#   --argjson enable_global_access true \
#   --argjson disable_cert_check true \
#   --argjson secure_credentials false \
#   "$(cat properties.jq)"
#

{
    ".register-service-broker.enable_global_access": {
      "value": $enable_global_access
    },
    ".deploy-service-broker.disable_cert_check": {
      "value": false
    },
    ".deploy-service-broker.secure_credentials": {
      "value": false
    },
    ".deploy-service-broker.persistence_store_service": {
      "value": "p.mysql"
    },
    ".deploy-service-broker.persistence_store_service_plan": {
      "value": "db-small"
    }
}
