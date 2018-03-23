# Pivotal Cloud Foundry Installation and Upgrade Automation

## The Automation Pipeline

![Install and Upgrade Pipeline](../../docs/images/pcf-install-and-upgrade-pipeline.png)

## Trouble shooting

* Job **PCF_install-and-upgrade/wipe-env** will fail if job **PCF_install-and-upgrade/create-infrastructure** failed before creation of the Ops Manager instance. If this happens then you will need to SSH to the Bastion instance as `vpn_admin` and become root. You will then need to hijack the failed **PCF_install-and-upgrade/create-infrastructure** job by referencing the last build or the build of a left-over container of the same job.

Once in the hijacked container invoke the `terraform destroy` command as follows.

    ```
    export GOOGLE_CREDENTIALS=${GCP_SERVICE_ACCOUNT_KEY}
    export GOOGLE_PROJECT=${GCP_PROJECT_ID}
    export GOOGLE_REGION=${GCP_REGION}

    terraform destroy -force \
        -var "gcp_proj_id=${GCP_PROJECT_ID}" \
        -var "gcp_region=${GCP_REGION}" \
        -var "gcp_zone_1=${GCP_ZONE_1}" \
        -var "gcp_zone_2=${GCP_ZONE_2}" \
        -var "gcp_zone_3=${GCP_ZONE_3}" \
        -var "gcp_storage_bucket_location=${GCP_STORAGE_BUCKET_LOCATION}" \
        -var "prefix=${GCP_RESOURCE_PREFIX}" \
        -var "pcf_opsman_image_name=${pcf_opsman_image_name}" \
        -var "pcf_ert_domain=${PCF_ERT_DOMAIN}" \
        -var "system_domain=${SYSTEM_DOMAIN}" \
        -var "apps_domain=${APPS_DOMAIN}" \
        -var "pcf_ert_ssl_cert=${pcf_ert_ssl_cert}" \
        -var "pcf_ert_ssl_key=${pcf_ert_ssl_key}" \
        -var "db_app_usage_service_username=${DB_APP_USAGE_SERVICE_USERNAME}" \
        -var "db_app_usage_service_password=${DB_APP_USAGE_SERVICE_PASSWORD}" \
        -var "db_autoscale_username=${DB_AUTOSCALE_USERNAME}" \
        -var "db_autoscale_password=${DB_AUTOSCALE_PASSWORD}" \
        -var "db_diego_username=${DB_DIEGO_USERNAME}" \
        -var "db_diego_password=${DB_DIEGO_PASSWORD}" \
        -var "db_notifications_username=${DB_NOTIFICATIONS_USERNAME}" \
        -var "db_notifications_password=${DB_NOTIFICATIONS_PASSWORD}" \
        -var "db_routing_username=${DB_ROUTING_USERNAME}" \
        -var "db_routing_password=${DB_ROUTING_PASSWORD}" \
        -var "db_uaa_username=${DB_UAA_USERNAME}" \
        -var "db_uaa_password=${DB_UAA_PASSWORD}" \
        -var "db_ccdb_username=${DB_CCDB_USERNAME}" \
        -var "db_ccdb_password=${DB_CCDB_PASSWORD}" \
        -var "db_accountdb_username=${DB_ACCOUNTDB_USERNAME}" \
        -var "db_accountdb_password=${DB_ACCOUNTDB_PASSWORD}" \
        -var "db_networkpolicyserverdb_username=${DB_NETWORKPOLICYSERVERDB_USERNAME}" \
        -var "db_networkpolicyserverdb_password=${DB_NETWORKPOLICYSERVERDB_PASSWORD}" \
        -var "db_nfsvolumedb_username=${DB_NFSVOLUMEDB_USERNAME}" \
        -var "db_nfsvolumedb_password=${DB_NFSVOLUMEDB_PASSWORD}" \
        -var "db_locket_username=${DB_LOCKET_USERNAME}" \
        -var "db_locket_password=${DB_LOCKET_PASSWORD}" \
        -var "db_silk_username=${DB_SILK_USERNAME}" \
        -var "db_silk_password=${DB_SILK_PASSWORD}" \
        -state terraform-state/terraform.tfstate \
        pcf-pipelines/install-pcf/gcp/terraform
    ```