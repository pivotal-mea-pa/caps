#
# jq -n \
#   --arg admin_password "Passw0rd" \
#   --arg server_plugins "rabbitmq_management" \
#   --arg ca_certs "$ca_certs" \
#   --arg rabbitmq_cert "" \
#   --arg rabbitmq_cert_key "" \
#   --arg external_dns_name "" \
#   --arg disk_alarm_threshold "mem_relative_1_5" \
#   --arg haproxy_static_ips "" \
#   --arg server_node_static_ips "" \
#   --arg syslog_address "" \
#   --argjson syslog_port null \
#   --arg syslog_transport "tcp" \
#   --argjson syslog_tls false \
#   --arg syslog_permitted_peer "" \
#   --arg syslog_ca_cert "" \
#   --argjson on_demand_service_instance_quota 20 \
#   --arg plan_1_cf_service_access "enable" \
#   --arg plan_1_name "single-node" \
#   --arg plan_1_description "This plan provides a single dedicated RabbitMQ node" \
#   --arg plan_1_features "RabbitMQ" \
#   --argjson plan_1_instance_quota 5 \
#   --argjson plan_1_number_of_nodes 1 \
#   --arg plan_1_cluster_strategy "pause_minority" \
#   --arg plan_1_vm_type "large" \
#   --arg plan_1_persistent_disk_type "30720" \
#   --arg availability_zones "europe-west1-b,europe-west1-c,europe-west1-d" \
#   "$(cat properties.jq)"
#

# RabbitMQ Configuration
{
  ".rabbitmq-server.server_admin_credentials": {
    "value": {
      "identity": "admin",
      "password": $admin_password
    },
  },
  ".rabbitmq-server.plugins": {
    "value": ($server_plugins | split(","))
  },
  ".rabbitmq-server.ssl_cacert": {
    "value": $ca_certs
  },
  ".rabbitmq-broker.dns_host": {
    "value": $external_dns_name
  },
  ".properties.disk_alarm_threshold": {
    "value": $disk_alarm_threshold
  },
  ".rabbitmq-haproxy.static_ips": {
    "value": $haproxy_static_ips,
  },
  ".rabbitmq-server.static_ips": {
    "value": $server_node_static_ips,
  },
}
+
if $server_tls_cert != "" then
{
  ".rabbitmq-server.rsa_certificate": {
    "value": {
      "cert_pem": $rabbitmq_cert,
      "private_key_pem": $rabbitmq_cert_key
    }
  }
}
else
.
end

# Network configuration
+
{
  ".rabbitmq-haproxy.static_ips": {
    "value": $haproxy_static_ips,
  },
  ".rabbitmq-server.static_ips": {
    "value": $server_node_static_ips,
  }
}

# Syslog configuration
+
if $syslog_address != "" then
{
    ".properties.syslog_selector": {
      "value": "enabled"
    },
    ".properties.syslog_selector.enabled.address": {
      "value": $syslog_address
    },
    ".properties.syslog_selector.enabled.port": {
      "value": $syslog_port
    },
    ".properties.syslog_selector.enabled.syslog_transport": {
      "value": $syslog_transport
    },
    ".properties.syslog_selector.enabled.syslog_tls": {
      "value": $syslog_tls
    },
    ".properties.syslog_selector.enabled.syslog_permitted_peer": {
      "value": $syslog_permitted_peer
    },
    ".properties.syslog_selector.enabled.syslog_ca_cert": {
      "value": $syslog_ca_cert
    }
}
else
{
  ".properties.syslog_selector": {
    "value": "disabled"
  }
}
end

# On demand global configuration
+
{
  ".on-demand-broker.global_service_instance_quota": {
    "value": $on_demand_service_instance_quota
  }
}

# Configure on-demand plan
+
{
    ".properties.on_demand_broker_plan_1_cf_service_access": {
      "value": $plan_1_cf_service_access,
    },
    ".properties.on_demand_broker_plan_1_name": {
      "value": $plan_1_name
    },
    ".properties.on_demand_broker_plan_1_description": {
      "value": $plan_1_description
     },
    ".properties.on_demand_broker_plan_1_features": {
      "value": $plan_1_features
    },
    ".properties.on_demand_broker_plan_1_instance_quota": {
      "value": $plan_1_instance_quota
    },
    ".properties.on_demand_broker_plan_1_rabbitmq_number_of_nodes": {
      "value": $plan_1_number_of_nodes
    },
    ".properties.on_demand_broker_plan_1_rabbitmq_cluster_partition_handling_strategy": {
      "value": $plan_1_cluster_strategy
    },
    ".properties.on_demand_broker_plan_1_rabbitmq_az_placement": {
      "value": ($availability_zones | split(","))
    },
    ".properties.on_demand_broker_plan_1_rabbitmq_vm_type": {
      "value": $plan_1_vm_type
    },
    ".properties.on_demand_broker_plan_1_rabbitmq_persistent_disk_type": {
      "value": $plan_1_persistent_disk_type
    },
    ".properties.on_demand_broker_plan_1_disk_limit_acknowledgement": {
      "value": [
        "acknowledge"
      ]
    }
}
