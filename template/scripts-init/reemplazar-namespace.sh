#!/bin/bash

reemplazar_apps_namespace(){
    find "$DIRECTORIO_APPS_NAMESPACE" \( -path "*/config/namespace/*.yaml" -o -path "*/namespace/*.yaml" \) | while read -r archivo; do
        sed -i "s/template-universidad/$MI_NAMESPACE/g" "$archivo"
    done
}

reemplazar_secrets_namespace(){
    find "$DIRECTORIO_SECRETS_NAMESPACE" -type f -name "*.yaml" | while read -r archivo; do
        sed -i "s/template-universidad/$MI_NAMESPACE/g" "$archivo"
    done
}