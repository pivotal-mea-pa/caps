#
# jq -n \
#   --arg gcp_project "$GCP_PROJECT" \
#   --arg default_deployment_tag "$DEPLOYMENT_PREFIX" \
#   --arg auth_json "$GCP_SERVICE_ACCOUNT_KEY"
#   "$(cat az_configuration.jq)"
#

{
  "project": $gcp_project,
  "default_deployment_tag": $default_deployment_tag,
  "auth_json": $auth_json
}
