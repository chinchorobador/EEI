#!/bin/bash

reemplazar_apps_namespace(){
    find "$DIRECTORIO_APPS_NAMESPACE" \( -path "*/namespace/*.yaml" \) | while read -r archivo; do
        sed -i "s/template-universidad/$MI_NAMESPACE/g" "$archivo"
    done
}