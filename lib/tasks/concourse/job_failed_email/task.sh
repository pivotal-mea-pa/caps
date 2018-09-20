#!/bin/bash

set -x
env

fly -t default login -c $CONCOURSE_URL -u ''$CONCOURSE_USER'' -p ''$CONCOURSE_PASSWORD''
fly -t default sync

pip install grip

job_output=$(fly -t local watch -j $BUILD_PIPELINE_NAME/$BUILD_JOB_NAME -b $BUILD_NAME)
echo -e "$job_output" | ./ansi2html.sh > email-out/job_output.html

cat <<EOF > body.md
## Job Access

You can view the failure on the Concourse Web UI by clicking on the link below.

[${BUILD_PIPELINE_NAME}/${BUILD_JOB_NAME}/${BUILD_NAME}]($ATC_EXTERNAL_URL/teams/$BUILD_TEAM_NAME/pipelines/$BUILD_PIPELINE_NAME/jobs/$BUILD_JOB_NAME/builds/$BUILD_NAME)

> In order to navigate to the link you need to ensure that the you have logged into the automation concourse environment via \`caps-login\`.

## Job Output

\`\`\`
$(echo -e "$job_output")
\`\`\`
EOF

grip body.md --title="Job Failure Report" --export email-out/body

cat <<EOF > email-out/subject
${ENVIRONMENT} Automation Job FAILED: ${BUILD_PIPELINE_NAME}/${BUILD_JOB_NAME}/${BUILD_NAME}
EOF

cat <<EOF > email-out/headers
MIME-version: 1.0
Content-Type: text/html; charset="UTF-8"
EOF
