#
# jq -n \
#   --arg trusted_certificates "$CA_CERTS" \
#   "$(cat security_configuration.jq)"
#

{
  "trusted_certificates": $trusted_certificates,
  "vm_password_type": "generate"
}
