#
# jq -n \
#    --arg harbor_registry_fqdn "harbor.pas.pcfenv1.pocs.pcfs.io" \
#    --arg harbor_registry_cert "$harbor_registry_cert" \
#    --arg harbor_registry_cert_key "$harbor_registry_cert_key" \
#    --arg server_cert_ca "$CA_CERTS" \
#    --arg admin_password "Passw0rd" \
#    --arg auth_mode "db_auth" \
#    --arg registry_storage "filesystem" \
#    "$(cat properties.jq)"
#

{
  ".properties.hostname": { "value": $harbor_registry_fqdn },
  ".properties.server_cert_key": {
    "value": {
      "cert_pem": $harbor_registry_cert,
      "private_key_pem": $harbor_registry_cert_key
    }
  },
  ".properties.server_cert_ca": { "value": $server_cert_ca },
  ".properties.admin_password": { "value": {
      "secret": $admin_password
    }
  },

  # Authentication: 
  #
  #   db_auth:      Internal
  #   ldap:         LDAP
  #   uaa_auth_pks: UAA in Pivotal Container Service 
  #   uaa_auth_pas: UAA in Pivotal Application Service
  #
  ".properties.auth_mode": { "value": $auth_mode },

  # Container Registry Storage:
  #
  #  filesystem: Local File System
  #  s3:         AWS S3
  #
  ".properties.registry_storage": { "value": $registry_storage }
}

# Configure LDAP authentication
+
if $auth_mode == "ldap_auth" then
{
  ".properties.auth_mode.ldap_auth.url": { "value": "" },
  ".properties.auth_mode.ldap_auth.verify_cert": { "value": false },
  ".properties.auth_mode.ldap_auth.timeout": { "value": 5 },

  # LDAP credentials
  ".properties.auth_mode.ldap_auth.searchdn": { "value": "" },
  ".properties.auth_mode.ldap_auth.searchpwd": {
    "value": {
      "secret": ""
    }
  },

  # LDAP Query
  ".properties.auth_mode.ldap_auth.basedn": { "value": "" },
  ".properties.auth_mode.ldap_auth.filter": { "value": "" },
  ".properties.auth_mode.ldap_auth.uid": { "value": "uid" },

  # LDAP Query Scope: 
  #
  #   1: Base
  #   2: OneLevel
  #   3: Subtree
  #
  ".properties.auth_mode.ldap_auth.scope": { "value": 2 }
}
else
.
end

# Configure S3 registry storage
+
if $registry_storage == "s3" then
{
    ".properties.registry_storage.s3.access_key": { "value": "" },
    ".properties.registry_storage.s3.secret_key": {
      "value": {
        "secret": ""
      }
    },
    ".properties.registry_storage.s3.region": { "value": "us-west-1" },
    ".properties.registry_storage.s3.endpoint_url": { "value": "" },
    ".properties.registry_storage.s3.bucket": { "value": "" },
    ".properties.registry_storage.s3.root_directory": { "value": "" }
}
else
.
end