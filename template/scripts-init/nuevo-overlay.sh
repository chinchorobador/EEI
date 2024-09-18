#!/bin/bash

source reemplazar-dominios.sh
source siu-secrets-config.sh
source registry-secrets-config.sh
source reemplazar-namespace.sh

MI_OVERLAY=$1
MI_DOMINIO=$2
MI_NAMESPACE=$3
DIRECTORIO=../../${MI_OVERLAY}

creacion_overlay(){
    rsync -a --quiet ../../template/ ../../${MI_OVERLAY}/ --exclude 'scripts-init'
    if [ $? -eq 1 ]; then
        echo -e "\nNo se ha podido crear el overlay $MI_OVERLAY"
        exit 1
    fi

    DIRECTORIO_APPS=../../${MI_OVERLAY}/apps
    DIRECTORIO_INGRESS=../../${MI_OVERLAY}/common/ingress
    DIRECTORIO_APPS_HUARPE_ENV=../../${MI_OVERLAY}/apps/huarpe/config
    DIRECTORIO_CONFIG_APPS=../../${MI_OVERLAY}/jobs/usuarios/config-apps/aplicaciones
    
    reemplazar_dominios_apps "$DIRECTORIO_APPS"
    reemplazar_dominios "$DIRECTORIO_INGRESS"
    reemplazar_dominios "$DIRECTORIO_CONFIG_APPS"
    reemplazar_dominios_huarpe_env "$DIRECTORIO_APPS_HUARPE_ENV"

    SECRETS_DIR=../../${MI_OVERLAY}/secrets

    generar_secrets "$SECRETS_DIR"
    generar_secrets_registry "$SECRETS_DIR"

    if [ $? -eq 1 ]; then
        echo -e "\nHubo un error al crear $MI_OVERLAY debido a un problema con el registry-secret.json, verifique la existencia y el contenido de dicho archivo."
        exit 1
    fi

    DIRECTORIO_APPS_NAMESPACE=../../${MI_OVERLAY}/apps
    reemplazar_apps_namespace "$DIRECTORIO_APPS_NAMESPACE"
    DIRECTORIO_SERVICES_NAMESPACE=../../${MI_OVERLAY}/services
    reemplazar_services_namespace "$DIRECTORIO_SERVICES_NAMESPACE"
    
    echo -e "\Se ha creado el overlay $MI_OVERLAY"
}

if [ -d "$DIRECTORIO" ]; then
    echo "Ya existe una carpeta que corresponde al overlay: $MI_OVERLAY"
    echo "Como desea seguir:"
    echo "R: Reemplazar"
    echo "N: Nuevo"
    echo "B: Borrar"
    while true; do
        read -p "Elige tu opción: " opt
        opt=$(echo $opt | tr '[:upper:]' '[:lower:]')
        case $opt in 
            "r") echo "Se sobrescribe la carpeta $MI_OVERLAY. Si ya tiene pods desplegados en el namespace $MI_NAMESPACE debe analizar de eliminarlos"
            creacion_overlay
            break;;
            "n") mv ../../${MI_OVERLAY}/ ../../OLD_${MI_OVERLAY}/
            echo "Se ha renombrado el overlay anterior"        
            break;;
            "b") rm -R ../../${MI_OVERLAY}/
            echo "Se ha borrado la carpeta del overlay"
            exit;;
        esac
    done
else

creacion_overlay

fi