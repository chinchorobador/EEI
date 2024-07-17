#!/bin/bash

source reemplazar-dominios.sh
source reemplazar-namespace.sh

MI_OVERLAY=$1
MI_DOMINIO=$2
MI_NAMESPACE=$3

rsync -av --progress ../../template/ ../../${MI_OVERLAY}/ --exclude 'scripts-init'

DIRECTORIO_APPS=../../${MI_OVERLAY}/apps
DIRECTORIO_INGRESS=../../${MI_OVERLAY}/common/ingress
DIRECTORIO_APPS_HUARPE_ENV=../../${MI_OVERLAY}/apps/huarpe/config
DIRECTORIO_CONFIG_APPS=../../${MI_OVERLAY}/jobs/usuarios/config-apps/aplicaciones

reemplazar_dominios_apps "$DIRECTORIO_APPS"
reemplazar_dominios "$DIRECTORIO_INGRESS"
reemplazar_dominios "$DIRECTORIO_CONFIG_APPS"
reemplazar_dominios_huarpe_env "$DIRECTORIO_APPS_HUARPE_ENV"

DIRECTORIO_COMMON_NAMESPACE=../../${MI_OVERLAY}/common/namespace
DIRECTORIO_SECRETS_NAMESPACE=../../${MI_OVERLAY}/secrets

reemplazar_common_namespace "$DIRECTORIO_COMMON_NAMESPACE"
reemplazar_secrets_namespace "$DIRECTORIO_SECRETS_NAMESPACE"