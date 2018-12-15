# Pivotal Cloud Foundry Installation and Upgrade Automation

## Terraform templates

The Terraform templates within this folder are used by concourse jobs to pave the IAAS and do post-install product configurations. You can apply these templates locally by retrieving the job inputs and exporting them using the following shell script.

```
caps-ci login

PIPELINE=SANDBOX_deployment
TASK_PRE=create-infrastructure
TASK_POST=save-terraform-output

eval $(fly -t local gp -p $PIPELINE \
  | awk "/task: $TASK_PRE/ { show=1 } show; /(on_failure:|task: $TASK_POST)/ { show=0 }" \
  | grep -A 1000 'params:' \
  | grep -v '\s*\(on_failure:\|\- task:\)\|^\s*params' \
  | sed 's|\\n|\\\\n|g' \
  | sed -e 's|^[[:space:]]*\([-_0-9a-zA-Z]*\): \(\S*\)|export \1=\2|' \
  | sed -e "s/=|/='/" \
  | sed "s/}/}'/")

export TF_VAR_pcf_opsman_image_name=$(fly -t local watch -j $PIPELINE/upload-opsman-image \
  | grep 'Downloading:.*Pivotal Cloud Foundry Ops Manager' \
  | sed 's|^.*GCP - \([0-9]*\.[0-9]*\)-build\.\([0-9]*\).*$|opsman-pcf-gcp-\1-build-\2|' \
  | sed 's|\.|\-|g')

rm -fr .terraform
terraform init \
  -backend-config="bucket=${TERRAFORM_STATE_BUCKET}" \
  -backend-config="prefix=${DEPLOYMENT_PREFIX}"
```
