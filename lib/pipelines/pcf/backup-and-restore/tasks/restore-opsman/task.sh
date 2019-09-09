#!/bin/bash

source ~/scripts/iaas-func.sh
source ~/scripts/opsman-func.sh
iaas::initialize

[[ -n "$TRACE" ]] && set -x
set -e

if [[ -n "$OPSMAN_SSH_PASSWD" ]]; then
    ssh_pass="sshpass -p$OPSMAN_SSH_PASSWD"
fi

source restore-timestamp/metadata

backup::download "$BACKUP_TYPE" "$BACKUP_TARGET" "$RESTORE_TIMESTAMP" opsman

set +e
uaac target https://$OPSMAN_HOST/uaa --skip-ssl-validation > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    set -e
    echo "Ops Manager has already been setup. The installation ZIP file cannot be imported."
    exit 1
fi
set -e

echo "Importing backed up export of installation..."
om -k -t https://$OPSMAN_HOST import-installation -dp $OPSMAN_DECRYPTION_KEY -i $backup_path/opsman/installation.zip

if [[ -d $backup_path/opsman/stemcells ]]; then
    for s in $(find $backup_path/opsman/stemcells -type f -print); do
        echo "Uploading stemcell '$s'..."
        om -k -t https://$OPSMAN_HOST -c $OPSMAN_CLIENT_ID -s $OPSMAN_CLIENT_SECRET upload-stemcell -s $s
    done
fi

#
# Check if Bosh Director exists
#

DIRECTOR_IP=$(cat $backup_path/opsman/installation.json \
    | jq -r '.ip_assignments.assignments
        | with_entries(select(.key|match("p-bosh-.*")))
        | to_entries[0].value
        | to_entries[0].value
        | to_entries[0].value[0]')

set +e
$ssh_pass ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $OPSMAN_SSH_USER@$OPSMAN_HOST \
    -- "echo $OPSMAN_SSH_PASSWD | sudo -S ping -c 1 $DIRECTOR_IP" | grep " 0% packet loss" > /dev/null 2>&1
if [[ $? -ne 0 ]]; then

    # Force Ops Manager to treat the deploy as a new deployment, recreating missing Virtual Machines (VMs), 
    # including BOSH. The new deployment ignores existing VMs such as your Pivotal Cloud Foundry deployment.

    echo "Bosh Director was not found! Doing a complete rebuild."
    $ssh_pass ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $OPSMAN_SSH_USER@$OPSMAN_HOST \
       -- "echo $OPSMAN_SSH_PASSWD | sudo -S mv /var/tempest/workspaces/default/deployments/bosh-state.json /var/tempest/workspaces/default/deployments/bosh-state.json.old"
fi
set -e

#
# Fix tiles with missing stemcells
#

opsman::kill_active_sessions
opsman::login_client $OPSMAN_HOST $OPSMAN_CLIENT_ID $OPSMAN_CLIENT_SECRET $OPSMAN_DECRYPTION_KEY
pivnet  login --api-token=$PIVNET_API_TOKEN

PRODUCTS_TO_FIX=$(opsman::get_installation | jq '.products[] | select(.stemcell==null) | .installation_name' | sed 's|"||g')
STEMCELL_VERSIONS_TO_GET=$(for p in $(echo -e "$PRODUCTS_TO_FIX"); do
    cat restore/installation.json | jq ".products[] | select(.installation_name==\"$p\") | .stemcell.version" | sed 's|"||g'
done | uniq)

for s in $(echo -e "$STEMCELL_VERSIONS_TO_GET"); do

    echo "Downloading missing stemcell '$s'..."
    pivnet  accept-eula --product-slug stemcells --release-version $s

    PRODUCT_FILE_DETAIL=$(pivnet  product-files --product-slug=stemcells --release-version $s \
        --format json | jq ".[] | select(.name | contains(\"vSphere\"))")
    
    FILE=$(echo -e "$PRODUCT_FILE_DETAIL" | jq .aws_object_key | sed 's|"||g')
    OUTPUT_FILE=stemcells/${FILE##*/}    
    URL=$(echo -e "$PRODUCT_FILE_DETAIL" | jq ._links.download.href | sed 's|"||g')
    
    wget --post-data '' --header "Authorization: Token $PIVNET_API_TOKEN" -O $OUTPUT_FILE $URL

    echo "Uploading stemcell '$s'..."
    om -k -t https://$OPSMAN_HOST -c $OPSMAN_CLIENT_ID -s $OPSMAN_CLIENT_SECRET upload-stemcell -s $OUTPUT_FILE
done

# Apply Pending Changes to Ops Manager Director only
om -k -t https://$OPSMAN_HOST -c $OPSMAN_CLIENT_ID -s $OPSMAN_CLIENT_SECRET apply-changes -i -sdp

# Source restore job environment for ops manager
source pipeline-src/scripts/prepare-opsman-restore.sh

set +e +x
