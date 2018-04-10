#!/bin/bash

function source_variables() {

    local var_file_glob=$1
    local var_file_path=$(dirname $var_file_glob)

    if [[ -e $var_file_path ]]; then
        eval "$(cat $var_file_path/pcf-env-*.sh | awk -F '=' '{ if ($2 != "") print toupper($1)"="$2; else print $0 }')"
    fi
}

function eval_jq_templates() {

  local tpl_name=$1
  local tpl_path=$2
  local tpl_override_path=$3

  tpls="\$(cat automation/$tpl_path/$tpl_name.jq)"
  args=$(cat automation/$tpl_path/$tpl_name.jq \
    | awk '/#/&& ($2 == "--arg" || $2== "--argjson") { 
        if ($2=="--arg") 
            print $2" "$3" \"$"toupper($3)"\""; 
        else 
            print $2" "$3" ${"toupper($3)":-null}";
    }')

  if [[ -n $tpl_override_path ]]; then
    for f in ./automation-extensions/$tpl_override_path/$tpl_name-*.jq; do
      [[ ! -e $f ]] && break

      tpls="$tpls | . |= . + \$(cat $f)"
      args="$args $(cat $f \
        | awk '/#/&& ($2 == "--arg" || $2== "--argjson") {
            if ($2=="--arg") 
                print $2" "$3" \"$"toupper($3)"\""; 
            else 
                print $2" "$3" ${"toupper($3)":-null}";
        }')"
    done
  fi

  eval 'jq -n '$args' "'$tpls'"'
}
