#
# jq -n \
#   --arg plan_1_multi_node_deployment true \
#   --arg plan_1_service_plan_access "enable" \
#   --arg plan_1_instance_limit 20 \
#   --arg plan_2_multi_node_deployment true \
#   --arg plan_2_service_plan_access "enable" \
#   --arg plan_2_instance_limit 20 \
#   --arg plan_3_multi_node_deployment true \
#   --arg plan_3_service_plan_access "enable" \
#   --arg plan_3_instance_limit 20 \
#   --arg s3_backup_access_key_id "" \
#   --arg s3_backup_secret_access_key "" \
#   --arg s3_backup_endpoint_url "" \
#   --arg s3_backup_region "" \
#   --arg s3_backup_bucket_name "" \
#   --arg s3_backup_path "" \
#   --arg scp_backup_user "" \
#   --arg scp_backup_server "" \
#   --arg scp_backup_destination "" \
#   --arg scp_backup_fingerprint "" \
#   --arg scp_backup_key "" \
#   --argjson scp_backup_port null \
#   --arg gcs_backup_project_id "" \
#   --arg gcs_backup_bucket_name "" \
#   --arg gcs_backup_service_account_json "" \
#   --arg azure_backup_account "" \
#   --arg azure_backup_storage_access_key "" \
#   --arg azure_backup_path "" \
#   --arg azure_backup_container "" \
#   --arg azure_backup_blob_store_base_url "" \
#   --arg backup_cron_schedule "0 */8 * * *" \
#   --argjson enable_backup_email_alerts false \
#   --arg syslog_address "" \
#   --argjson syslog_port null \
#   --arg syslog_transport "tcp" \
#   --argjson syslog_tls false \
#   --arg syslog_permitted_peer "" \
#   --arg syslog_ca_cert "" \
#   --arg availability_zones "$AVAILABILITY_ZONES" \
#   "$(cat properties.jq)"
#

# Plan configuration
if $plan_1_instance_limit > 0 then
{
    ".properties.plan1_selector": {
      "value": "Active"
    },
    ".properties.plan1_selector.active.multi_node_deployment": {
      "value": $plan_1_multi_node_deployment
    },
    ".properties.plan1_selector.active.access_dropdown": {
      "value": $plan_1_service_plan_access
    },
    ".properties.plan1_selector.active.az_multi_select": {
      "value": ($availability_zones | split(","))
    },
    ".properties.plan1_selector.active.instance_limit": {
      "value": $plan_1_instance_limit
    }
}
else
{
  ".properties.plan1_selector": {
    "value": "Inactive"
  }
}
end
+
if $plan_2_instance_limit > 0 then
{
    ".properties.plan2_selector": {
      "value": "Active"
    },
    ".properties.plan2_selector.active.multi_node_deployment": {
      "value": $plan_2_multi_node_deployment
    },
    ".properties.plan2_selector.active.access_dropdown": {
      "value": $plan_2_service_plan_access
    },
    ".properties.plan2_selector.active.az_multi_select": {
      "value": ($availability_zones | split(","))
    },
    ".properties.plan2_selector.active.instance_limit": {
      "value": $plan_2_instance_limit
    }
}
else
{
  ".properties.plan2_selector": {
    "value": "Inactive"
  }
}
end
+
if $plan_3_instance_limit > 0 then
{
    ".properties.plan3_selector": {
      "value": "Active"
    },
    ".properties.plan3_selector.active.multi_node_deployment": {
      "value": $plan_3_multi_node_deployment
    },
    ".properties.plan3_selector.active.access_dropdown": {
      "value": $plan_3_service_plan_access
    },
    ".properties.plan3_selector.active.az_multi_select": {
      "value": ($availability_zones | split(","))
    },
    ".properties.plan3_selector.active.instance_limit": {
      "value": $plan_3_instance_limit
    }
}
else
{
  ".properties.plan3_selector": {
    "value": "Inactive"
  }
}
end

# Backup configuration
+
if $s3_backup_access_key_id != "" then
{
    ".properties.backups_selector": {
      "value": "S3 Backups"
    },
    ".properties.backups_selector.s3.access_key_id": {
      "value": $s3_backup_access_key_id
    },
    ".properties.backups_selector.s3.secret_access_key": {
      "value": $s3_backup_secret_access_key
    },
    ".properties.backups_selector.s3.endpoint_url": {
      "value": $s3_backup_endpoint_url
    },
    ".properties.backups_selector.s3.region": {
      "value": $s3_backup_region,
    },
    ".properties.backups_selector.s3.bucket_name": {
      "value": $s3_backup_bucket_name
    },
    ".properties.backups_selector.s3.path": {
      "value": $s3_backup_path
    },
    ".properties.backups_selector.s3.cron_schedule": {
      "value": $backup_cron_schedule
    },
    ".properties.backups_selector.s3.enable_email_alerts": {
      "value": $enable_backup_email_alerts
    }
}
elif $scp_backup_server != "" then
{
    ".properties.backups_selector": {
      "value": "SCP Backups"
    },
    ".properties.backups_selector.scp.user": {
      "value": $scp_backup_user
    },
    ".properties.backups_selector.scp.server": {
      "value": $scp_backup_server
    },
    ".properties.backups_selector.scp.destination": {
      "value": $scp_backup_destination
    },
    ".properties.backups_selector.scp.fingerprint": {
      "value": $scp_backup_fingerprint
    },
    ".properties.backups_selector.scp.key": {
      "value": $scp_backup_key
    },
    ".properties.backups_selector.scp.port": {
      "value": $scp_backup_port
    },
    ".properties.backups_selector.scp.cron_schedule": {
      "value": $backup_cron_schedule
    },
    ".properties.backups_selector.scp.enable_email_alerts": {
      "value": $enable_backup_email_alerts
    }
}
elif $gcs_backup_project_id != "" then
{
    ".properties.backups_selector": {
      "value": "GCS Backups"
    },
    ".properties.backups_selector.gcs.project_id": {
      "value": $gcs_backup_project_id
    },
    ".properties.backups_selector.gcs.bucket_name": {
      "value": $gcs_backup_bucket_name
    },
    ".properties.backups_selector.gcs.service_account_json": {
      "value": $gcs_backup_service_account_json
    },
    ".properties.backups_selector.gcs.cron_schedule": {
      "value": $backup_cron_schedule
    },
    ".properties.backups_selector.gcs.enable_email_alerts": {
      "value": $enable_backup_email_alerts
    }
} 
elif $azure_backup_account != "" then
{
    ".properties.backups_selector": {
      "value": "Azure Backups"
    },
    ".properties.backups_selector.azure.account": {
      "value": $azure_backup_account
    },
    ".properties.backups_selector.azure.storage_access_key": {
      "value": $azure_backup_storage_access_key
    },
    ".properties.backups_selector.azure.path": {
      "value": $azure_backup_path
    },
    ".properties.backups_selector.azure.container": {
      "value": $azure_backup_container
    },
    ".properties.backups_selector.azure.blob_store_base_url": {
      "value": $azure_backup_blob_store_base_url
    },
    ".properties.backups_selector.azure.cron_schedule": {
      "value": $backup_cron_schedule
    },
    ".properties.backups_selector.azure.enable_email_alerts": {
      "value": $enable_backup_email_alerts
    }
}
else
{
    ".properties.backups_selector": {
      "value": "SCP Backups"
    },
    ".properties.backups_selector.scp.user": {
      "value": "noop"
    },
    ".properties.backups_selector.scp.server": {
      "value": "noop"
    },
    ".properties.backups_selector.scp.destination": {
      "value": "noop"
    },
    ".properties.backups_selector.scp.fingerprint": {
      "value": "noop"
    },
    ".properties.backups_selector.scp.key": {
      "value": {
        "secret": "noop"
      }
    },
    ".properties.backups_selector.scp.port": {
      "value": 22
    },
    ".properties.backups_selector.scp.cron_schedule": {
      # A CRON schedule that never runs (i.e. February 31st)
      "value": "0 0 31 2 *"
    },
    ".properties.backups_selector.scp.enable_email_alerts": {
      "value": false
    }
}
end

# Syslog configuration
+
if $syslog_address != "" then
{
    ".properties.syslog_migration_selector": {
      "value": "enabled"
    },
    ".properties.syslog_migration_selector.enabled.address": {
      "value": $syslog_address
    },
    ".properties.syslog_migration_selector.enabled.port": {
      "value": $syslog_port
    },
    ".properties.syslog_migration_selector.enabled.transport_protocol": {
      "value": $syslog_transport
    },
    ".properties.syslog_migration_selector.enabled.tls_enabled": {
      "value": $syslog_tls
    },
    ".properties.syslog_migration_selector.enabled.permitted_peer": {
      "value": $syslog_permitted_peer
    },
    ".properties.syslog_migration_selector.enabled.ca_cert": {
      "value": $syslog_ca_cert
    }
}
else
{
  ".properties.syslog_migration_selector": {
    "value": "disabled"
  }
}
end