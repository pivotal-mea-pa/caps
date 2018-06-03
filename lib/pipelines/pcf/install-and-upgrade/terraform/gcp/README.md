# Pivotal Cloud Foundry Installation and Upgrade Automation

## Terraform templates

The Terraform templates within this folder are used by the the `create-infrastructure` job to pave the IAAS. You can apply these templates locally by retrieving the job inputs and exporting them using the following shell script.

```
caps-ci login

eval $(fly -t local gp -p PCF_install-and-upgrade \
  | awk '/task: create-infrastructure/ { show=1 } show; /task: save-terraform-output/ { show=0 }' \
  | grep -A 1000 'params:' \
  | grep -v '\s*\- task:\|^\s*params' \
  | sed 's|\\n|\\\\n|g' \
  | sed -e 's|^[[:space:]]*\([-_0-9a-zA-Z]*\): \(\S*\)|export \1=\2|' \
  | sed -e "s/=|/='/" \
  | sed "s/}/}'/")

export TF_VAR_pcf_opsman_image_name=$(fly -t local watch -j PCF_install-and-upgrade/upload-opsman-image \
  | grep 'Downloading:.*Pivotal Cloud Foundry Ops Manager' \
  | sed 's|^.*GCP - \([0-9]*\.[0-9]*\)-build\.\([0-9]*\).*$|opsman-pcf-gcp-\1-build-\2|' \
  | sed 's|\.|\-|g')

rm -fr .terraform
terraform init \
  -backend-config="bucket=${TERRAFORM_STATE_BUCKET}" \
  -backend-config="prefix=${GCP_RESOURCE_PREFIX}"
```
