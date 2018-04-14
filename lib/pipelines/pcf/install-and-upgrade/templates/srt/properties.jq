#
# jq -n \
#   --arg iaas "gcp" \
#   --arg s3_access_key "$AWS_ACCESS_KEY" \
#   --arg s3_secret_key "$AWS_SECRET_KEY" \
#   --arg s3_region "$AWS_DEFAULT_REGION" \
#   --arg s3_endpoint "" \
#   --arg gcp_storage_access_key "$GCS_STORAGE_ACCESS_KEY" \
#   --arg gcp_storage_secret_key "$GCS_STORAGE_SECRET_KEY" \
#   --arg terraform_prefix "$terraform_prefix" \
#   --arg system_domain "sys.pas.pcfenv1.pocs.pcfs.io" \
#   --arg apps_domain "apps.pas.pcfenv1.pocs.pcfs.io" \
#   --arg router_static_ips "" \
#   --arg diego_brain_static_ips "" \
#   --arg ha_proxy_static_ips "" \
#   --arg tcp_router_static_ips "" \
#   --arg ert_certificate "" \
#   --arg ert_certificate_key "" \
#   --arg routing_custom_ca_certificates "" \
#   --arg routing_tls_termination "load_balancer" \
#   --arg router_tls_ciphers "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384" \
#   --arg haproxy_tls_ciphers "DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384" \
#   --arg haproxy_forward_tls "enable" \
#   --arg haproxy_backend_ca "$ROOT_CA" \
#   --argjson skip_cert_verify true \
#   --argjson routing_disable_http false \
#   --arg container_networking_network_cidr "10.255.0.0/16" \
#   --arg container_networking_dns_servers "" \
#   --arg tcp_routing "enable" \
#   --arg tcp_routing_reservable_ports "20000-40000" \
#   --argjson allow_app_ssh_access true \
#   --argjson default_app_ssh_access true \
#   --arg security_acknowledgement "X" \
#   --arg insecure_docker_registry_list "" \
#   --arg saml_certificate "" \
#   --arg saml_certificate_key "" \
#   --arg credhub_primary_encryption_name "default" \
#   --arg credhub_encryption_key_name1 "default" \
#   --arg credhub_encryption_key_secret1 "" \
#   --arg credhub_encryption_key_name2 "" \
#   --arg credhub_encryption_key_secret2 "" \
#   --arg credhub_encryption_key_name3 "" \
#   --arg credhub_encryption_key_secret3 "" \
#   --arg database_type "internal_mysql" \
#   --arg db_host "" \
#   --arg db_port "3306" \
#   --arg db_uaa_username "cf_db_user" \
#   --arg db_uaa_password "DbP@ssw0rd" \
#   --arg db_app_usage_service_username "cf_db_user" \
#   --arg db_app_usage_service_password "DbP@ssw0rd" \
#   --arg db_autoscale_username "cf_db_user" \
#   --arg db_autoscale_password "DbP@ssw0rd" \
#   --arg db_diego_username "cf_db_user" \
#   --arg db_diego_password "DbP@ssw0rd" \
#   --arg db_notifications_username "cf_db_user" \
#   --arg db_notifications_password "DbP@ssw0rd" \
#   --arg db_routing_username "cf_db_user" \
#   --arg db_routing_password "DbP@ssw0rd" \
#   --arg db_ccdb_username "cf_db_user" \
#   --arg db_ccdb_password "DbP@ssw0rd" \
#   --arg db_accountdb_username "cf_db_user" \
#   --arg db_accountdb_password "DbP@ssw0rd" \
#   --arg db_networkpolicyserverdb_username "cf_db_user" \
#   --arg db_networkpolicyserverdb_password "DbP@ssw0rd" \
#   --arg db_nfsvolumedb_username "cf_db_user" \
#   --arg db_nfsvolumedb_password "DbP@ssw0rd" \
#   --arg db_locket_username "cf_db_user" \
#   --arg db_locket_password "DbP@ssw0rd" \
#   --arg db_silk_username "cf_db_user" \
#   --arg db_silk_password "DbP@ssw0rd" \
#   --arg mysql_proxy_static_ips "" \
#   --arg mysql_monitor_recipient_email "admin@caps.cloud" \
#   --arg company_name "Pivotal" \

#
# Domains
#

{
  ".cloud_controller.system_domain": { "value": $system_domain },
  ".cloud_controller.apps_domain": { "value": $apps_domain },
}

#
# Networking
#
+
{
  ".router.static_ips": { "value": ($router_static_ips | split(",")) },
  ".diego_brain.static_ips": { "value": ($diego_brain_static_ips | split(",")) },
  ".ha_proxy.static_ips": { "value": ($ha_proxy_static_ips | split(",")) },
  ".tcp_router.static_ips": { "value": ($tcp_router_static_ips | split(",")) },

  # Certificates and Private Keys for HAProxy and Router
  ".properties.networking_poe_ssl_certs": {
    "value": [ 
      {
        "name": "ERT SAN Certificate",
        "certificate": {
          "cert_pem": $ert_certificate,
          "private_key_pem": $ert_certificate_key
        }
      }
    ]
  },
  
  ".properties.routing_custom_ca_certificates": { "value": $routing_custom_ca_certificates },
  ".properties.routing_tls_termination": { "value": $routing_tls_termination },

  # TLS Cipher Suites
  ".properties.gorouter_ssl_ciphers": { "value": $router_tls_ciphers },
  ".properties.haproxy_ssl_ciphers": { "value": $haproxy_tls_ciphers },
}
+
# TLS between HAProxy/Load Balancer and Router
if $haproxy_forward_tls == "enable" then
{
  ".properties.haproxy_forward_tls": { "value": $haproxy_forward_tls },
  ".properties.haproxy_forward_tls.enable.backend_ca": { "value": $haproxy_backend_ca }
}
else
{
  ".properties.haproxy_forward_tls": { "value": $haproxy_forward_tls }
}
end
+
{
  ".ha_proxy.skip_cert_verify": { "value": $skip_cert_verify },
  ".properties.routing_disable_http": { "value": $routing_disable_http },

  ".properties.route_services": { "value": "enable" },
  ".properties.route_services.enable.ignore_ssl_cert_verification": { "value": true },

  ".properties.container_networking_interface_plugin.silk.network_cidr": { "value": $container_networking_network_cidr },
  ".properties.container_networking_interface_plugin.silk.dns_servers": { "value": $container_networking_dns_servers }
}
+
# TLS between HAProxy/Load Balancer and Router
if $tcp_routing == "enable" then
{
  ".properties.tcp_routing": { "value": $tcp_routing },
  ".properties.tcp_routing.enable.reservable_ports": { "value": $tcp_routing_reservable_ports }
}
else
{
  ".properties.tcp_routing": { "value": $tcp_routing },
}
end
+
# logger_endpoint_port
if $iaas == "aws" then
  {
    ".properties.logger_endpoint_port": { "value": 4443 }
  }
else
  .
end

+
#
# Application Containers
#
{
  ".cloud_controller.allow_app_ssh_access": { "value": $allow_app_ssh_access },
  ".cloud_controller.default_app_ssh_access": { "value": $default_app_ssh_access },
}

#
# Application Developer Controls
#

#
# Application Security Groups
#
+
{
  ".properties.security_acknowledgement": { "value": $security_acknowledgement }
}

#
# Authentications and Enterprise SSO
#
+
{
  ".diego_cell.insecure_docker_registry_list": { "value": ($insecure_docker_registry_list | split(",")) }
}

#
# UAA
#
+
if $database_type == "external" then
{
  ".properties.uaa_database": { "value": $database_type },
  ".properties.uaa_database.external.host": { "value": $db_host },
  ".properties.uaa_database.external.port": { "value": $db_port },
  ".properties.uaa_database.external.uaa_username": { "value": $db_uaa_username },
  ".properties.uaa_database.external.uaa_password": { "value": { "secret": $db_uaa_password } },
}
else
{
  ".properties.uaa_database": { "value": $database_type },
}
end
+
{
  ".uaa.service_provider_key_credentials": {
    "value": {
      "cert_pem": $saml_certificate,
      "private_key_pem": $saml_certificate_key
    }
  }
}

# Credhub
+
{
  ".properties.credhub_key_encryption_passwords": {
    "value": []
  }
}
|
if $credhub_encryption_key_name1 != "" then
  .".properties.credhub_key_encryption_passwords".value[.".properties.credhub_key_encryption_passwords".value| length] |= . + 
  {
    "name": $credhub_encryption_key_name1,
    "primary": ($credhub_encryption_key_name1 == $credhub_primary_encryption_name),
    "key": {
      "secret": $credhub_encryption_key_secret1
    }
  } 
else
  .
end
|
if $credhub_encryption_key_name2 != "" then
  .".properties.credhub_key_encryption_passwords".value[.".properties.credhub_key_encryption_passwords".value| length] |= . + 
  {
    "name": $credhub_encryption_key_name2,
    "primary": ($credhub_encryption_key_name2 == $credhub_primary_encryption_name),
    "key": {
      "secret": $credhub_encryption_key_secret2,
    }
  } 
else
  .
end
|
if $credhub_encryption_key_name3 != "" then
  .".properties.credhub_key_encryption_passwords".value[.".properties.credhub_key_encryption_passwords".value| length] |= . + 
  {
    "name": $credhub_encryption_key_name3,
    "primary": ($credhub_encryption_key_name3 == $credhub_primary_encryption_name),
    "key": {
      "secret": $credhub_encryption_key_secret3,
    }
  } 
else
  .
end

#
# Databases
#
+
if $database_type == "external" then
{
  ".properties.system_database": { "value":  $database_type },
  ".properties.system_database.external.host": { "value": $db_host },
  ".properties.system_database.external.port": { "value": $db_port },
  ".properties.system_database.external.app_usage_service_username": { "value": $db_app_usage_service_username },
  ".properties.system_database.external.app_usage_service_password": { "value": { "secret": $db_app_usage_service_password } },
  ".properties.system_database.external.autoscale_username": { "value": $db_autoscale_username },
  ".properties.system_database.external.autoscale_password": { "value": { "secret": $db_autoscale_password } },
  ".properties.system_database.external.diego_username": { "value": $db_diego_username },
  ".properties.system_database.external.diego_password": { "value": { "secret": $db_diego_password } },
  ".properties.system_database.external.notifications_username": { "value": $db_notifications_username },
  ".properties.system_database.external.notifications_password": { "value": { "secret": $db_notifications_password } },
  ".properties.system_database.external.routing_username": { "value": $db_routing_username },
  ".properties.system_database.external.routing_password": { "value": { "secret": $db_routing_password } },
  ".properties.system_database.external.ccdb_username": { "value": $db_ccdb_username },
  ".properties.system_database.external.ccdb_password": { "value": { "secret": $db_ccdb_password } },
  ".properties.system_database.external.account_username": { "value": $db_accountdb_username },
  ".properties.system_database.external.account_password": { "value": { "secret": $db_accountdb_password } },
  ".properties.system_database.external.networkpolicyserver_username": { "value": $db_networkpolicyserverdb_username },
  ".properties.system_database.external.networkpolicyserver_password": { "value": { "secret": $db_networkpolicyserverdb_password } },
  ".properties.system_database.external.nfsvolume_username": { "value": $db_nfsvolumedb_username },
  ".properties.system_database.external.nfsvolume_password": { "value": { "secret": $db_nfsvolumedb_password } },
  ".properties.system_database.external.locket_username": { "value": $db_locket_username },
  ".properties.system_database.external.locket_password": { "value": { "secret": $db_locket_password } },
  ".properties.system_database.external.silk_username": { "value": $db_silk_username },
  ".properties.system_database.external.silk_password": { "value": { "secret": $db_silk_password } }
}
else
{
  ".properties.system_database": { "value":  $database_type }
}
end

#
# Internal MySQL
#
+
{
  ".mysql_proxy.static_ips": { "value": ($mysql_proxy_static_ips | split(",")) },
  ".mysql_monitor.recipient_email": { "value" : $mysql_monitor_recipient_email }
}

# File Storage
+
if $iaas == "aws" then
  {
    ".properties.system_blobstore": { "value": "external" },
    ".properties.system_blobstore.external.buildpacks_bucket": { "value": "\($terraform_prefix)-buildpacks" },
    ".properties.system_blobstore.external.droplets_bucket": { "value": "\($terraform_prefix)-droplets" },
    ".properties.system_blobstore.external.packages_bucket": { "value": "\($terraform_prefix)-packages" },
    ".properties.system_blobstore.external.resources_bucket": { "value": "\($terraform_prefix)-resources" },
    ".properties.system_blobstore.external.access_key": { "value": $s3_access_key },
    ".properties.system_blobstore.external.secret_key": { "value": { "secret": $s3_secret_key } },
    ".properties.system_blobstore.external.signature_version.value": { "value": "4" },
    ".properties.system_blobstore.external.region": { "value": $s3_region },
    ".properties.system_blobstore.external.endpoint": { "value": $s3_endpoint }
  }
elif $iaas == "gcp" then
  {
    ".properties.system_blobstore": { "value": "external_gcs" },
    ".properties.system_blobstore.external_gcs.buildpacks_bucket": { "value": "\($terraform_prefix)-buildpacks" },
    ".properties.system_blobstore.external_gcs.droplets_bucket": { "value": "\($terraform_prefix)-droplets" },
    ".properties.system_blobstore.external_gcs.packages_bucket": { "value": "\($terraform_prefix)-packages" },
    ".properties.system_blobstore.external_gcs.resources_bucket": { "value": "\($terraform_prefix)-resources" },
    ".properties.system_blobstore.external_gcs.access_key": { "value": $gcp_storage_access_key },
    ".properties.system_blobstore.external_gcs.secret_key": { "value": { "secret": $gcp_storage_secret_key } }
  }
else
  .
end

# System Logging
+
{
  ".cloud_controller.security_event_logging_enabled": { "value": true },
}

# Custom Branding

# Apps Manager
+
{
  ".properties.push_apps_manager_company_name": { "value": $company_name },
}

# Email Notifications

# App Autoscaler

# Cloud Controller

# Smoke Tests

# Advanced Features
