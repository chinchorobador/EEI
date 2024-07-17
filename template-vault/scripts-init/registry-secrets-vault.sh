#!/bin/bash

DIR_SECRETS=$1

store_registry_secret_in_vault() {
    REGS=$(jq -r 'keys | .[]' < registry-secrets.json)
    echo "${REGS}" | while read CFG; do
        URL=$(jq -r '."'${CFG}'".url' < registry-secrets.json)
        USERNAME=$(jq -r '."'${CFG}'".username' < registry-secrets.json)
        PASSWORD=$(jq -r '."'${CFG}'".password' < registry-secrets.json)
        AUTH=$(echo -n ${USERNAME}:${PASSWORD} | base64)
        
        json_data=$(jq -n --arg url "$URL" --arg auth "$AUTH" \
        '{"auths": {($url): {"auth": $auth}}}')

        local path="expedientes/data/${DIR_SECRETS}/registry/${CFG}"

        curl -X POST \
            http://localhost:36155/v1/${path} \
            -H 'Content-Type: application/json' \
            -H "X-Vault-Token: hvs.UEoQsOcsv9DWNCHScDPsu8eh" \
            -d "{\"data\": {\".dockerconfigjson\": ${json_data}}}"
    done
}

store_registry_secret_in_vault