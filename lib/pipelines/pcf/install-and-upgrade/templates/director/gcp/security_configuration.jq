#
# jq -n \
#   --arg trusted_certificates "$OPS_MGR_TRUSTED_CERTS" \
#   "$(cat security_configuration.jq)"
#

{
  "trusted_certificates": $trusted_certificates,
  "vm_password_type": "generate"
}
