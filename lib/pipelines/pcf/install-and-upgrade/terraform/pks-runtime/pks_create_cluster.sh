#!/bin/bash

# Check if all the required CLIs are available
which bosh 2>&1 > /dev/null
if [ $? -ne 0 ]; then
  which bosh-cli 2>&1 > /dev/null
  if [ $? -ne 0 ]; then
    echo "ERROR! Unable to find bosh cli."
    exit 1
  fi
  bosh="bosh-cli"
else
  bosh="bosh"
fi

which pks >/dev/null 2>&1 || (echo "Error! 'pks' cli not found" && exit 1)
#which bosh >/dev/null 2>&1 || (echo "Error! 'bosh' cli not found" && exit 1)
which kubectl >/dev/null 2>&1 || (echo "Error! 'kubectl' cli not found" && exit 1)

set -eu

pks login --skip-ssl-validation \
  --api ${pks_url} --username ${user} --password ${password}

cluster_uuid=$(pks cluster ${cluster_name} --json 2>/dev/null | jq -r .uuid)
if [[ -z $cluster_uuid ]]; then
  cluster_uuid=$(pks create-cluster ${cluster_name} --json --non-interactive \
    --external-hostname ${cluster_name}.${cluster_domain} \
    --plan ${plan} \
    | jq -r .uuid)
fi

status=$(pks cluster ${cluster_name} --json | jq -r "\"\(.last_action) \(.last_action_state)\"")
while [[ $status == "CREATE in progress" ]]; do

  bosh_tasks=$(bosh\
    --environment=${bosh_host} --ca-cert="${ca_cert}" \
    --client=${bosh_client_id} --client-secret=${bosh_client_secret} --json tasks)

  task_id=$(echo "$bosh_tasks" \
    | jq -r ".Tables[0].Rows[] | select(.deployment==\"service-instance_$cluster_uuid\") | .id")

  if [[ -n $task_id ]]; then
    bosh\
      --environment=${bosh_host} --ca-cert="${ca_cert}" \
      --client=${bosh_client_id} --client-secret=${bosh_client_secret} \
      task $task_id
  fi

  status=$(pks cluster ${cluster_name} --json | jq -r "\"\(.last_action) \(.last_action_state)\"")
done

echo "${password}" | pks get-credentials pks-releng
kubectl config use-context ${cluster_name}
