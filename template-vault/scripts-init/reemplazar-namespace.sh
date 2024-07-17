#!/bin/bash

reemplazar_common_namespace(){
    find "$DIRECTORIO_COMMON_NAMESPACE" -type f -name "*.yaml" | while read -r archivo; do
        sed -i "s/template-universidad/$MI_NAMESPACE/g" "$archivo"
    done
}

reemplazar_secrets_namespace(){
    find "$DIRECTORIO_SECRETS_NAMESPACE" -type f -name "*.yaml" | while read -r archivo; do
        sed -i "s/template-universidad/$MI_NAMESPACE/g" "$archivo"
    done
}