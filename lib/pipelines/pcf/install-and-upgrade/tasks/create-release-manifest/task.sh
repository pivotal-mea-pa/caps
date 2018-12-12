#!/bin/bash

[[ -n "$TRACE" ]] && set -x
set -eu

# Ensure all input is passed thruough to output
cp -r input-files/* output-files 2>/dev/null || :
cp versions/versions* output-files 2>/dev/null || :

versions_file=output-files/$(basename output-files/versions*)
if [[ ! -e $versions_file ]]; then
  versions_file=output-files/versions
  touch $versions_file
fi

environment=$(echo $ENVIRONMENT | awk '{print toupper($0)}')

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

installed_products=$(om \
  --skip-ssl-validation \
  --target "https://${OPSMAN_HOST}" \
  --client-id "${OPSMAN_CLIENT_ID}" \
  --client-secret "${OPSMAN_CLIENT_SECRET}" \
  --username "${OPSMAN_USERNAME}" \
  --password "${OPSMAN_PASSWORD}" \
  deployed-products \
  --format json)

resources=$(curl -s $CONCOURSE_URL/api/v1/teams/main/pipelines/download-products/resources \
  -X GET -H "Authorization: Bearer $concourse_auth_token" \
  | jq -r '.[] | select(.name | match(".*-download")) | .name' \
  | sort)

manifest_table='
<style type="text/css">
  table,
  th,
  td {
    border-collapse: collapse;
  }

  .manifest table,
  .manifest th,
  .manifest td {
    border: 1px solid black;
    border-collapse: collapse;
  }
</style>
<table cellspacing="0" cellpadding="0" border="0" style="min-width:800px; max-width:1280px; width:100%;">
  <tr><td style="padding-left:10px;"><h2>Product Release Manifest</h2></td></tr>
  <tr>
    <td align="center" valign="top" style="padding:10px;">
      <table width="100%" cellpadding="5" class="manifest">
        <tr>
          <th colspan="2" />
          <th colspan="3" align="center">Versions</th>
          <th />
        </tr>
        <tr>
          <th width="10%">Product</th>
          <th width="8%">Last Update</th>
          <th width="8%">Downloaded</th>
          <th width="8%">Available</th>
          <th width="8%">Installed</th>
          <th>Release Highlights</th>
        </tr>'

for r in $resources; do

  set +eu

  p=${r%-download}

  # Special case where products pas-small and pas are the same
  [[ $p != "pas-small" ]] || p="pas"

  product=$(echo $p | awk '{print toupper($0)}')

  release=$(curl -s $CONCOURSE_URL/api/v1/teams/main/pipelines/download-products/resources/$r/versions \
    -X GET -H "Authorization: Bearer $concourse_auth_token" \
    | jq '
      [ 
        .[].metadata | select(. != null)
        | map( { (.name): .value } ) 
        | add 
        | with_entries(select([.key] | inside(["version", "release_date", "description", "release_notes_url"]))) 
      ] 
      | sort_by(.release_date) | last')

  version=$(echo $release | jq -r .version)
  release_date=$(echo $release | jq -r .release_date)

  available_release=$(curl -s $CONCOURSE_URL/api/v1/teams/main/pipelines/${environment}_deployment/resources/$p-tile/versions \
    -X GET -H "Authorization: Bearer $concourse_auth_token" \
    | jq -r '
      [ 
        .[].metadata | select(. != null)
        | map( { (.name): .value } ) 
        | add 
      ] 
      | first | .filename')

  available_version=$(echo $available_release | sed -e 's|.*_\([0-9]*.[0-9]*.[0-9]*\)_.*|\1|')

  name=${available_release%.tgz}
  om_product=${name#*_${available_version}_}

  om_version=$(echo $installed_products \
    | jq -r '.[] | select(.name | match("'$om_product'";"i")) | .version')
  installed_version=${om_version%-*}

  grep "$product|$version" $versions_file
  if [[ $? -eq 0 ]]; then
    row_style="style='$VERSION_ROW_STYLE'"
  else
    row_style="style='$NEW_VERSION_ROW_STYLE'"
    grep "$product|" $versions_file  \
      && sed -i "s|$product\|.*|$product\|$version|" $versions_file \
      || echo "$product|$version" >> $versions_file
  fi

  read -r -d "" product_release <<EOV
<tr ${row_style}>
  <td style="font-weight:bold;">${product}</td>
  <td align="center">${release_date}</td>
  <td align="center">${version}</td>
  <td align="center">${available_version}</td>
  <td align="center">${installed_version}</td>
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

echo "${manifest_table}"'
      </table>
    </td>
  </tr>
</table>' > job_message

iconv -c -f utf-8 -t ascii job_message > output-files/job_message

python <<EOL > output-files/manifest.html
import string, sys 

with open('automation/lib/pipelines/pcf/install-and-upgrade/tasks/create-release-manifest/manifest.html', 'r') as f:
    manifest_html=f.read()
with open('output-files/job_message', 'r') as f:
    release_table=f.read()

t = string.Template(manifest_html)
v = {'release_table': release_table}
print(t.substitute(v))
EOL
