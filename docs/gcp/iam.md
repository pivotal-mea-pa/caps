# GCP IaaS Pre-requisites

1. Within Google Cloud Platform, enable the following:
  * GCP Compute API [here](https://console.cloud.google.com/apis/api/compute_component)
  * GCP Storage API [here](https://console.cloud.google.com/apis/api/storage_component)
  * GCP SQL API [here](https://console.cloud.google.com/apis/api/sql_component)
  * GCP DNS API [here](https://console.cloud.google.com/apis/api/dns)
  * GCP Cloud Resource Manager API [here](https://console.cloud.google.com/apis/api/cloudresourcemanager.googleapis.com/overview)
  * GCP Storage Interopability [here](https://console.cloud.google.com/storage/settings)

2. Create a bucket in Google Cloud Storage to hold the initial Terraform state file, enabling versioning for this bucket via:
  * the `gsutil` CLI: `gcloud auth activate-service-account --key-file credentials.json && gsutil versioning set on gs://<your-bucket>`
  * If you already have a service account and sufficient permissions, you can run `gcloud auth login` and `gsutil versioning set on gs://<your-bucket>`
