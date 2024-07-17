#!/bin/bash

generar_secrets_registry(){
    mkdir -p ${SECRETS_DIR}

    REGS=$(jq -r 'keys | .[]' <registry-secrets.json)
    echo "${REGS}" | while read CFG; do
        URL=$(jq -r '."'${CFG}'".url' <registry-secrets.json)
        USERNAME=$(jq -r '."'${CFG}'".username' <registry-secrets.json)
        PASWORD=$(jq -r '."'${CFG}'".password' <registry-secrets.json)
        AUTH=$(echo -n ${USERNAME}:${PASWORD} | base64)
        cat > ${SECRETS_DIR}/${CFG} <<- DOCKERCONFIG
    {
        "auths": {
            "${URL}": {
                "auth": "${AUTH}"
            }
        }
    }
DOCKERCONFIG
done
}