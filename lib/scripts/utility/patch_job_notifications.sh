#!/bin/bash

if [[ $# < 1 ]]; then
  echo -e "\nUSAGE: /patch_job_notifications.sh <PATH_TO_PIPELINE_YML> [ <SUBJECT_HEADING> ]\n"
  exit 1
fi

if [[ -z $2 ]]; then
  subject_heading="automation job "
else
  subject_heading="$2 "
fi

set -euo pipefail

pipeline=$(cat $1)
jobs=$(echo -e "$pipeline" \
  | awk '/- task: notify on (.*) (success|failure)/{ print $5 }' \
  | uniq)

if [[ -z $jobs ]]; then
  echo -e "$pipeline"
  exit 0
fi

cat <<'EOF' > notification-patch.yml
EOF

for j in $(echo -e "$jobs"); do 

  alert_on_success=$(echo -e "$pipeline" | awk "/- task: notify on $j success/{ print \"y\" }")
  alert_on_failure=$(echo -e "$pipeline" | awk "/- task: notify on $j failure/{ print \"y\" }")

  cat <<EOF >> notification-patch.yml
EOF

  if [[ -n $alert_on_success ]]; then

    cat <<EOF >> notification-patch.yml

- type: remove
  path: /jobs/name=$j/on_success/do/task=notify on $j success

- type: replace
  path: /jobs/name=$j/on_success?/do?/-
  value:
    task: job_succeeded_alert
    config:
      platform: linux
      image_resource:
        type: docker-image
        source: {repository: alpine}
      run:
        path: echo NOOOP
EOF

  fi

  if [[ -n $alert_on_failure ]]; then

    cat <<EOF >> notification-patch.yml
    
- type: remove
  path: /jobs/name=$j/on_failure/do/task=notify on $j failure

- type: replace
  path: /jobs/name=$j/on_failure?/do?/-
  value:
    task: job_failed_alert
    config:
      platform: linux
      image_resource:
        type: docker-image
        source: {repository: alpine}
      run:
        path: echo NOOOP
EOF

  fi

done

set +e
which bosh 2>&1 > /dev/null
if [ $? -ne 0 ]; then
    which bosh-cli 2>&1 > /dev/null
    if [ $? -ne 0 ]; then
        echo "ERROR! Unable to find bosh cli."
        exit 1
    fi
    set -e
    bosh-cli interpolate -o notification-patch.yml $1
else
    set -e
    bosh interpolate -o notification-patch.yml $1
fi
