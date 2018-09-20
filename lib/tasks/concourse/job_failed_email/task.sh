#!/bin/bash

set -x
env

fly -t default login -c $CONCOURSE_URL -u ''$CONCOURSE_USER'' -p ''$CONCOURSE_PASSWORD''
fly -t default sync

build_name=$(fly -t local builds | awk -v j="$PIPELINE_JOB_PATH" '($2 == j){ print $3 }' | sort | tail -1)
job_output=$(fly -t local watch -j $PIPELINE_JOB_PATH -b $build_name)
echo -e "$job_output" | ./ansi2html.sh > email-out/body

cat <<EOF > email-out/headers
MIME-version: 1.0
Content-Type: text/html; charset="UTF-8"
EOF
