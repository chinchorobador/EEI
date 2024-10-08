#!/bin/bash

reemplazar_apps_namespace(){
    find "$DIRECTORIO_APPS_NAMESPACE" \( -path "*/namespace/*.yaml" -o -path "*/config/*.env" -o -path "*/config/*.json" \) | while read -r archivo; do
        sed -i "s/template-universidad/$MI_NAMESPACE/g" "$archivo"
    done
}

reemplazar_services_namespace(){
    find "$DIRECTORIO_SERVICES_NAMESPACE" \( -path "*/namespace/*.yaml" \) | while read -r archivo; do
        sed -i "s/template-universidad/$MI_NAMESPACE/g" "$archivo"
    done
}

reemplazar_secrets_namespace(){
    find "$SECRETS_DIR" \( -path "*.env" \) | while read -r archivo; do
        sed -i "s/template-universidad/$MI_NAMESPACE/g" "$archivo"
    done
}