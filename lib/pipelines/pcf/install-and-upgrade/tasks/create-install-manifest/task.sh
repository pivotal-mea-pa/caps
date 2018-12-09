#!/bin/bash

[[ -n "$TRACE" ]] && set -x
set -eu

#
# Login to concourse and retrieve the token
#

fly -t local login -k -c "$CONCOURSE_URL" -u "$CONCOURSE_USER" -p "$CONCOURSE_PASSWORD"

concourse_auth_token=$(python <<PYTHON
import yaml, json, sys
flyrc=yaml.load(open('/root/.flyrc', 'r'))
print(flyrc['targets']['local']['token']['value'])
PYTHON
)

# Retrieve all tile download resource names from download pipeline

team_name=main
pipeline_name=download-products

resources=$(curl -s $CONCOURSE_URL/api/v1/teams/$team_name/pipelines/$pipeline_name/resources \
  -X GET -H "Authorization: Bearer $concourse_auth_token" \
  | jq -r '.[] | select(.name | match(".*-download")) | .name' \
  | sort)

manifest_table='
<table width="100%" cellpadding="5" class="manifest">
<tr>
  <th width="12%">Product</th>
  <th width="12%">Version</th>
  <th width="18%">Release Date</th>
  <th>Release Highlights</th>
</tr>
'

echo "" > install_manifest/versions

for r in $resources; do

  release=$(curl -s $CONCOURSE_URL/api/v1/teams/$team_name/pipelines/$pipeline_name/resources/$r/versions \
    -X GET -H "Authorization: Bearer $concourse_auth_token" \
    | jq '
      [ 
        .[].metadata | select(. != null)
        | map( { (.name): .value } ) 
        | add 
        | with_entries(select([.key] 
        | inside(["version", "release_date", "description", "release_notes_url"]))) 
      ] 
      | sort_by(.release_date) | last')

  set +eu

  product=$(echo ${r%-download} | awk '{print toupper($0)}')
  version=$(echo $release | jq -r .version)
  release_date=$(echo $release | jq -r .release_date)

  row_style="style='$NEW_VERSION_ROW_STYLE'"
  if [[ -e versions/versions ]]; then
    grep "$product|$version" versions/versions
    [[ $? -eq 0 ]] && row_style="style='$VERSION_ROW_STYLE'"
  fi

  echo "$product|$version" >> install_manifest/versions

  read -r -d "" product_release <<EOV
<tr ${row_style}>
  <td style="font-weight:bold;">${product}</td>
  <td align="center">${version}</td>
  <td align="center">${release_date}</td>
  <td>
EOV

  release_notes_url=$(echo "$release" | jq -r .release_notes_url)
  description=$(echo "$release" | jq -r .description | sed 's|\*|-|g' | sed 's|•|-|g')

  unset in_list
  while IFS= read -r line; do

    first_char=$(echo $line | cut -c1)
    if [[ "$first_char" == "-" ]]; then
      
      if [[ -z $in_list ]]; then
        product_release="${product_release}<ul style='list-style-type:square'>"
        in_list=1
      fi
  
      product_release="${product_release}<li>${line:1:9999}</li>"
    else

      if [[ -n $in_list ]]; then
        product_release="${product_release}</ul>"
        unset in_list
      fi

      product_release="${product_release}<p>${line}</p>"
    fi

  done < <(printf '%s\n' "$description")

  if [[ -n $in_list ]]; then
    product_release="${product_release}</ul>"
  fi

  product_release="${product_release}<p align='right'><small>[<a href='$release_notes_url'>Release Notes</a>]</small></p>"
  manifest_table="${manifest_table}${product_release}</td></tr>"

  set -eu
done

echo "${manifest_table}</table>" > releases.html
iconv -c -f utf-8 -t ascii releases.html > install_manifest/releases.html

python <<EOL > install_manifest/manifest.html
import string, sys 

with open('automation/lib/pipelines/pcf/install-and-upgrade/tasks/create-install-manifest/manifest.html', 'r') as f:
    manifest_html=f.read()
with open('install_manifest/releases.html', 'r') as f:
    release_table=f.read()

t = string.Template(manifest_html)
v = {'release_table': release_table}
print(t.substitute(v))
EOL
