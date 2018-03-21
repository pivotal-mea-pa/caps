# Pivotal Cloud Foundry deployment

This automation recipe will build a complete Pivotal Cloud Foundry deployment end-to-end. It will also setup automation pipelines to upgrade and patch, backup/restore and start/stop the deployed services.

## Deploy recipe to Google Cloud

## Initialize backend state

```
cd <THIS DIRECTORY>/gcp

export TF_VAR_bootstrap_state_bucket=<GS bucket to save the Terraform bootstrap state>
export TF_VAR_bootstrap_state_prefix=<GS bucket path to save Terraform bootstrap state>

terraform init \
    -backend-config="bucket=$TF_VAR_bootstrap_state_bucket" \
    -backend-config="prefix=$TF_VAR_bootstrap_state_prefix" \
```

## Bootstrap environment

```
cd <THIS DIRECTORY>/gcp

export TF_VAR_bootstrap_state_bucket=<GS bucket to save the Terraform bootstrap state>
export TF_VAR_bootstrap_state_prefix=<GS bucket path to save Terraform bootstrap state>

terraform plan \
    -var="bootstrap_state_bucket=$TF_VAR_bootstrap_state_bucket" \
    -var="bootstrap_state_prefix=$TF_VAR_bootstrap_state_prefix"

terraform apply -auto-approve \
    -var="bootstrap_state_bucket=$TF_VAR_bootstrap_state_bucket" \
    -var="bootstrap_state_prefix=$TF_VAR_bootstrap_state_prefix"
```

## Deploy recipe to AWS

TBD

## Deploy recipe to Azure

TBD

## Deploye recipe to VMWare vCenter

TBD