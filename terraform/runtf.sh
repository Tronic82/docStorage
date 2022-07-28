#!/usr/bin/env bash

function tfinit
{
    terraform init -input=false
    if [ "$?" != "0" ]
    then
        terraform init -input=false -reconfigure || { echo 'aborting build, unable to init terraform'; exit 1; }
    fi
    terraform providers
}

# check for appropriate usage of the script
if [[ $# -lt 2 ]]
then
    echo "usage: $0 <environment> in form development or production, <apply> in form Y or N"
    exit 1
fi

backend_file="backend.$1"

if [[ ! -f "$backend_file" ]]
then
    echo "please create a backend.<environment> file in $(dirname "$0")"
    exit 1
fi
_APPLY=$2

var_file="$1.tfvars"

cmp -s "backend.tf" ${backend_file}
if [ "$?" != "0" ]
then
    cp ${backend_file} backend.tf
    echo "terraform using backend state for environment: $1"
    tfinit
fi
 
if [ "${_APPLY}" = "Y" ]
then
    echo "in APPLY mode for environment: $1"
    terraform plan -input=false -no-color --var-file=${var_file} --out plantodo.plan || exit 1
    terraform apply -input=false -no-color -auto-approve plantodo.plan
else
    echo "in PLAN mode for environment: $1"
    terraform plan -input=false -no-color --var-file=${var_file} || exit 1
fi