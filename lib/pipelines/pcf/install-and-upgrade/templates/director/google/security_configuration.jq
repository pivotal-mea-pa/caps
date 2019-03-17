#
# jq -n \
#   --arg trusted_certificates "$CA_CERTS" \
#   "$(cat security_configuration.jq)"
#

{
  "trusted_certificates": $trusted_certificates,
  "opsmanager_root_ca_trusted_certs": true,
  "vm_password_type": "generate"
}
