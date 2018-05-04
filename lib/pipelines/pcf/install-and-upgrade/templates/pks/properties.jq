#
# jq -n \
#    --arg pks_api_url "pks.sys.pas.pcfenv1.pocs.pcfs.io" \
#    --arg pks_certificate "$pks_certificate" \
#    --arg pks_certificate_key "$pks_certificate_key" \
#    --arg cloud_provider "gcp" \
#    --arg gcp_master_service_account_key "$GCP_SERVICE_ACCOUNT_KEY" \
#    --arg gcp_worker_service_account_key "$GCP_SERVICE_ACCOUNT_KEY" \
#    --arg gcp_project_id "$GCP_PROJECT_ID" \
#    --arg vpc_network_name "${TF_VAR_prefix}-virt-net" \
#    --argjson plan1_worker_instances 3 \
#    --argjson plan1_allow_privileged_containers false \
#    --arg plan1_az_placement "europe-west1-b" \
#    --argjson plan2_worker_instances 5 \
#    --argjson plan2_allow_privileged_containers false \
#    --arg plan2_az_placement "europe-west1-c" \
#    --argjson plan3_worker_instances 0 \
#    --argjson plan3_allow_privileged_containers false \
#    --arg plan3_az_placement "europe-west1-d" \
#    "$(cat properties.jq)"
#

{
  ".properties.uaa_url": { "value": $pks_api_url },
  ".pivotal-container-service.pks_tls": {
    "value": {
      "cert_pem": $pks_certificate,
      "private_key_pem": $pks_certificate_key
    }
  }
}

# Configure plans
+
if $plan1_worker_instances > 0 then
{
  ".properties.plan1_selector": { "value": "Plan Active" },
  ".properties.plan1_selector.active.name": { "value": "small" },
  ".properties.plan1_selector.active.description": { "value": "Default plan for K8s cluster" },
  ".properties.plan1_selector.active.az_placement": { "value": $plan1_az_placement },
  ".properties.plan1_selector.active.authorization_mode": { "value": "rbac" },
  ".properties.plan1_selector.active.master_vm_type": { "value": "medium" },
  ".properties.plan1_selector.active.master_persistent_disk_type": { "value": "10240" },
  ".properties.plan1_selector.active.worker_vm_type": { "value": "medium" },
  ".properties.plan1_selector.active.persistent_disk_type": { "value": "10240" },
  ".properties.plan1_selector.active.worker_instances": { "value": $plan1_worker_instances },
  ".properties.plan1_selector.active.errand_vm_type": { "value": "micro" },
  ".properties.plan1_selector.active.addons_spec": { "value": "" },
  ".properties.plan1_selector.active.allow_privileged_containers": { "value": $plan1_allow_privileged_containers }
}
else
{ 
  ".properties.plan1_selector": { "value": "Plan Inactive" } 
}
end
+
if $plan2_worker_instances > 0 then
{
  ".properties.plan2_selector": { "value": "Plan Active" },
  ".properties.plan2_selector.active.name": { "value": "medium" },
  ".properties.plan2_selector.active.description": { "value": "For Large Workloads" },
  ".properties.plan2_selector.active.az_placement": { "value": $plan2_az_placement },
  ".properties.plan2_selector.active.authorization_mode": { "value": "rbac" },
  ".properties.plan2_selector.active.master_vm_type": { "value": "large" },
  ".properties.plan2_selector.active.master_persistent_disk_type": { "value": "10240" },
  ".properties.plan2_selector.active.worker_vm_type": { "value": "medium" },
  ".properties.plan2_selector.active.persistent_disk_type": { "value": "10240" },
  ".properties.plan2_selector.active.worker_instances": { "value": $plan2_worker_instances },
  ".properties.plan2_selector.active.errand_vm_type": { "value": "micro" },
  ".properties.plan2_selector.active.addons_spec": { "value": "" },
  ".properties.plan2_selector.active.allow_privileged_containers": { "value": $plan2_allow_privileged_containers }
}
else
{ 
  ".properties.plan2_selector": { "value": "Plan Inactive" } 
}
end
+
if $plan3_worker_instances > 0 then
{
  ".properties.plan3_selector": { "value": "Plan Active" },
  ".properties.plan3_selector.active.name": { "value": "large" },
  ".properties.plan3_selector.active.description": { "value": "For Extra Large Workloads" },
  ".properties.plan3_selector.active.az_placement": { "value": $plan3_az_placement },
  ".properties.plan3_selector.active.authorization_mode": { "value": "rbac" },
  ".properties.plan3_selector.active.master_vm_type": { "value": "xlarge" },
  ".properties.plan3_selector.active.master_persistent_disk_type": { "value": "10240" },
  ".properties.plan3_selector.active.worker_vm_type": { "value": "xlarge" },
  ".properties.plan3_selector.active.persistent_disk_type": { "value": "10240" },
  ".properties.plan3_selector.active.worker_instances": { "value": $plan3_worker_instances },
  ".properties.plan3_selector.active.errand_vm_type": { "value": "micro" },
  ".properties.plan3_selector.active.addons_spec": { "value": "" },
  ".properties.plan3_selector.active.allow_privileged_containers": { "value": $plan3_allow_privileged_containers }
}
else
{ 
  ".properties.plan3_selector": { "value": "Plan Inactive" } 
}
end

# Configure cloud provider
+
if $cloud_provider == "gcp" then
{
  ".properties.cloud_provider": { "value": "GCP" },
  ".properties.cloud_provider.gcp.master_service_account_key": { "value": $gcp_master_service_account_key },
  ".properties.cloud_provider.gcp.worker_service_account_key": { "value": $gcp_worker_service_account_key },
  ".properties.cloud_provider.gcp.project_id": { "value": $gcp_project_id },
  ".properties.cloud_provider.gcp.network": { "value": $vpc_network_name },
}
elif $cloud_provider == "vsphere" then
{
  ".properties.cloud_provider": { "value": "vSphere" },
  ".properties.cloud_provider.vsphere.vcenter_creds": { "value": "" },
  ".properties.cloud_provider.vsphere.vcenter_ip": { "value": "" },
  ".properties.cloud_provider.vsphere.vcenter_dc": { "value": "" },
  ".properties.cloud_provider.vsphere.vcenter_ds": { "value": "" },
  ".properties.cloud_provider.vsphere.vcenter_vms": { "value": "" }
}
else
.
end
