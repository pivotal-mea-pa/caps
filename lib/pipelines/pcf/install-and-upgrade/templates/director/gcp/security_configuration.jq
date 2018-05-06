#
# jq -n \
#   --arg trusted_certificates "$ca_certs" \
#   "$(cat security_configuration.jq)"
#

{
  "trusted_certificates": $trusted_certificates,
  "vm_password_type": "generate"
}
