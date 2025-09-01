#!/bin/bash

reemplazar_dominios_apps(){
    # apps/config
    find "$DIRECTORIO_APPS" -type d -name "config" -exec sh -c 'find "$0" -type f \( -name "*.yaml" -o -name "*.json" -o -name "*.env" \)' {} \; | while read -r archivo; do
        sed -i "s/uunn.local/$MI_DOMINIO/g" "$archivo"
    done
}

reemplazar_dominios() {
    # ingress y config-apps
    find "$1" -type f \( -name "*.yaml" -o -name "*.json" -o -name "*.env" \) | while read -r archivo; do
        sed -i "s/uunn.local/$MI_DOMINIO/g" "$archivo"
    done
}

reemplazar_dominios_huarpe_proveedor_env() {
    local DIRECTORIO_ENV="$1"
    # escapar caracteres
    MI_DOMINIO_ESCAPADO=$(printf '%s\n' "$MI_DOMINIO" | sed -e 's/[]\/$*.^[]/\\\\&/g')
    # huarpe-proveedor/env
    find "$DIRECTORIO_ENV" -type f -name "*.env" | while read -r archivo; do
        sed -i 's/uunn\\.local/'"$MI_DOMINIO_ESCAPADO"'/g' "$archivo"
    done
}