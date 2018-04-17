#!/bin/bash

function source_variables() {

  local var_file_glob=$1
  local var_file_path=$(dirname $var_file_glob)

  if [[ -e $var_file_path ]]; then
    eval "$(cat $var_file_path/pcf-env-*.sh | awk -F '=' '{ if ($2 != "") print toupper($1)"="$2; else print $0 }')"
  fi
}

function eval_jq_templates() {

  [[ -n "$TRACE" ]] && set -x

  local tpl_name=$1
  local tpl_path=$2
  local tpl_override_path=$3

  if [[ -n $4 ]]; then
    # Append IAAS directory to template path
    tpl_path=$tpl_path/$4
    tpl_override_path=$tpl_override_path/$4
  fi

  tpls="\$(cat $tpl_path/$tpl_name.jq)"
  args=$(cat $tpl_path/$tpl_name.jq \
    | awk -v q="'" '/#/&& ($2 == "--arg" || $2== "--argjson") { 
        if ($2=="--arg") 
            print $2" "$3" \"${" toupper($3) ":-" $4 "}\" "; 
        else 
            print $2" "$3" ${" toupper($3) ":-" q $4 q "} ";
    }' \
    | tr -d '\n')

  if [[ -n $tpl_override_path && -e $tpl_override_path ]]; then
    for f in $tpl_override_path/$tpl_name-*.jq; do
      [[ ! -e $f ]] && break

      tpls="$tpls | . |= . + \$(cat $f)"
      args="$args "$(cat $f \
        | awk -v q="'" '/#/&& ($2 == "--arg" || $2== "--argjson") { 
            if ($2=="--arg") 
                print $2" "$3" \"${" toupper($3) ":-" $4 "}\" "; 
            else 
                print $2" "$3" ${" toupper($3) ":-" q $4 q "} ";
        }' \
        | tr -d '\n')
    done
  fi

  eval 'jq -n '$args' "'$tpls'"'
}
