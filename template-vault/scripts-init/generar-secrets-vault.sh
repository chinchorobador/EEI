#!/bin/bash

DIR_SECRETS=$1

PWDGEN="cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1"

# Función para almacenar múltiples secretos en Vault
store_secret_in_vault() {
    local path=$1
    shift
    local json_data
    if [[ $path == "expedientes/data/${DIR_SECRETS}/sudocu-api-secret" ]]; then
        local inner_json_data=""
        for kv in "$@"; do
            local key=$(echo $kv | cut -d= -f1)
            local value=$(echo $kv | cut -d= -f2)
            inner_json_data+="\"$key\":\"${value}\","
        done
        inner_json_data=$(echo $inner_json_data | sed 's/,$//')
        local json_data="{\"data\":{\"sudocu-api-server-secret.json\":{$inner_json_data}}}"
    else
        local json_data="{\"data\":{"
        for kv in "$@"; do
            local key=$(echo $kv | cut -d= -f1)
            local value=$(echo $kv | cut -d= -f2 | sed 's/"/\\"/g')
            json_data+="\"$key\":\"${value}\","
        done
        json_data=$(echo $json_data | sed 's/,$//')
        json_data+="}}"
    fi
    curl -X POST \
        http://localhost:43095/v1/${path} \
        -H 'Content-Type: application/json' \
        -H "X-Vault-Token: hvs.UEoQsOcsv9DWNCHScDPsu8eh" \
        -d "$json_data"
}

export POSTGRES_USERNAME=postgres
export POSTGRES_PASSWORD=$(eval ${PWDGEN})

export LDAP_ADMIN_PASSWORD=$(eval ${PWDGEN})
export LDAP_CONFIG_PASSWORD=$(eval ${PWDGEN})

export MINIO_USERNAME=minio
export MINIO_PASSWORD=$(eval ${PWDGEN})

export NUXEO_USERNAME=Administrator
export NUXEO_PASSWORD=$(eval ${PWDGEN})

# Aplicaciones

export API_DOCS_USERNAME=documentos
export API_DOCS_PASSWORD=$(eval ${PWDGEN})
export API_PERSONAS_USERNAME=personas
export API_PERSONAS_PASSWORD=$(eval ${PWDGEN})
export API_USUARIOS_USERNAME=usuarios
export API_USUARIOS_PASSWORD=$(eval ${PWDGEN})
export API_SUDOCU_USERNAME=integracion
export API_SUDOCU_PASSWORD=$(eval ${PWDGEN})

export API_DIAGUITA_USERNAME=diaguita
export API_DIAGUITA_PASSWORD=$(eval ${PWDGEN})
export API_GUARANI_USERNAME=guarani
export API_GUARANI_PASSWORD=$(eval ${PWDGEN})
export API_KOLLA_USERNAME=kolla
export API_KOLLA_PASSWORD=$(eval ${PWDGEN})
export API_MAPUCHE_USERNAME=mapuche
export API_MAPUCHE_PASSWORD=$(eval ${PWDGEN})
export API_PILAGA_USERNAME=pilaga
export API_PILAGA_PASSWORD=$(eval ${PWDGEN})
export API_PROVEEDORES_USERNAME=proveedores
export API_PROVEEDORES_PASSWORD=$(eval ${PWDGEN})
export API_GUARANI_USERNAME=guarani
export API_GUARANI_PASSWORD=$(eval ${PWDGEN})

export API_FIRMAR_USERNAME=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
export API_FIRMAR_PASSWORD=

export USUARIOS_TOBA_PASSWORD=$(eval ${PWDGEN})
export USUARIOS_IDP_CLAVE_CONSOLA=$(eval ${PWDGEN})
export USUARIOS_SEGURIDAD_ALGORITMO_SALT=$(eval ${PWDGEN})

export DOCS_STAMPER_KEYSTORE_PASS=1234

# servicios postgres/ldap/minio/nuxeo
store_secret_in_vault expedientes/data/${DIR_SECRETS}/postgres POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
store_secret_in_vault expedientes/data/${DIR_SECRETS}/ldap LDAP_ADMIN_PASSWORD=${LDAP_ADMIN_PASSWORD} LDAP_CONFIG_PASSWORD=${LDAP_CONFIG_PASSWORD}
store_secret_in_vault expedientes/data/${DIR_SECRETS}/minio MINIO_ROOT_USER=${MINIO_USERNAME} MINIO_ROOT_PASSWORD=${MINIO_PASSWORD}
store_secret_in_vault expedientes/data/${DIR_SECRETS}/nuxeo NUXEO_USERNAME=${NUXEO_USERNAME} NUXEO_PASSWORD=${NUXEO_PASSWORD}

# Docs
store_secret_in_vault expedientes/data/${DIR_SECRETS}/documentos \
    ARAI_DOCS_DB_PASSWORD=${POSTGRES_PASSWORD} \
    ARAI_DOCS_NUXEO_CLAVE=${NUXEO_PASSWORD} \
    ARAI_DOCS_S3_SECRET=${MINIO_PASSWORD} \
    ARAI_DOCS_PASS=${API_DOCS_PASSWORD} \
    PERSONAS_PARAMS="\"{base_uri:'http://personas-api:8080/api/v1/',method:'basic',user:'${API_PERSONAS_USERNAME}',password:'${API_PERSONAS_PASSWORD}'}\"" \
    SERVICIO_FIRMAR_PARAMS="\"{base_uri:'https://tst.firmar.gob.ar/',method:'basic',user:'${API_FIRMAR_USERNAME}',password:'${API_FIRMAR_PASSWORD}'}\"" \
    TRAMITES_PARAMS="\"{base_uri:'http://sudocu-api-server:8080/',method:'basic',user:'${API_SUDOCU_USERNAME}',password:'${API_SUDOCU_PASSWORD}'}\"" \
    USUARIOS_PARAMS="\"{base_uri:'http://usuarios-api/api/v1/usuarios',method:'basic',user:'${API_USUARIOS_USERNAME}',password:'${API_USUARIOS_PASSWORD}'}\""

# Docs-stamper
store_secret_in_vault expedientes/data/${DIR_SECRETS}/docs-stamper \
    ARAI_DOCS_STAMPER_KEYSTORE_PASS=${DOCS_STAMPER_KEYSTORE_PASS}

# Personas
store_secret_in_vault expedientes/data/${DIR_SECRETS}/personas \
    DB_PASSWORD=${POSTGRES_PASSWORD} \
    API_BASIC_CLIENTES=[[\"${API_PERSONAS_USERNAME}\",\"${API_PERSONAS_PASSWORD}\"]]

# Usuarios
store_secret_in_vault expedientes/data/${DIR_SECRETS}/usuarios \
    TOBA_PASSWORD=${USUARIOS_TOBA_PASSWORD} \
    DB_PASSWORD=${POSTGRES_PASSWORD} \
    IDP_CLAVE_CONSOLA=${USUARIOS_IDP_CLAVE_CONSOLA} \
    LDAP_BINDPASS=${LDAP_ADMIN_PASSWORD} \
    SEGURIDAD_ALGORITMO_SALT=${USUARIOS_SEGURIDAD_ALGORITMO_SALT} \
    API_BASIC_CLIENTES=[[\"${API_USUARIOS_USERNAME}\",\"${API_USUARIOS_PASSWORD}\"]] \
    CREDENCIALES_API_BASIC_PERSONAS=[[\"${API_PERSONAS_USERNAME}\",\"${API_PERSONAS_PASSWORD}\",\"http://personas-api:8080/api/v1/\"]]

# Huarpe
store_secret_in_vault expedientes/data/${DIR_SECRETS}/huarpe \
    API_DOCS_PASS=${API_DOCS_PASSWORD} \
    API_USUARIOS_PASS=${API_USUARIOS_PASSWORD}

# Sudocu
store_secret_in_vault expedientes/data/${DIR_SECRETS}/sudocu \
    SUDOCU_DB_USER=${POSTGRES_USERNAME} \
    SUDOCU_DB_PASSWORD=${POSTGRES_PASSWORD}

# Sudocu-api-server-secret.json 
store_secret_in_vault expedientes/data/${DIR_SECRETS}/sudocu-api-secret \
    "auth_providers_basic_password=${API_SUDOCU_PASSWORD}" \
    "repositorios_arai_password=${API_DOCS_PASSWORD}" \
    "firma_password=${API_DOCS_PASSWORD}" \
    "db_password=${POSTGRES_PASSWORD}" \
    "redis_options_password=redis"


########  Satelites  ########

# Diaguita
store_secret_in_vault expedientes/data/${DIR_SECRETS}/diaguita \
    PROYECTO_DB_PASSWORD=${POSTGRES_PASSWORD} \
    TOBA_DB_PASSWORD=${POSTGRES_PASSWORD} \
    ARAI_PROV_DB_PASSWORD=${POSTGRES_PASSWORD} \
    API_BASIC_CLIENTES=[[\"${API_DIAGUITA_USERNAME}\",\"${API_DIAGUITA_PASSWORD}\"]] \
    DOCUMENTOS_CLAVE=${API_DOCS_PASSWORD} \
    CREDENCIALES_API_BASIC_REST_ARAI_USUARIOS=[[\"${API_USUARIOS_USERNAME}\",\"${API_USUARIOS_PASSWORD}\",\"http://usuarios-api/api/v1/\"]] \
    CREDENCIALES_API_BASIC_MAPUCHE=[[\"${API_MAPUCHE_USERNAME}\",\"${API_MAPUCHE_PASSWORD}\",\"http://mapuche/mapuche/rest/v1/\"]] \
    CREDENCIALES_API_BASIC_PILAGA=[[\"${API_PILAGA_USERNAME}\",\"${API_PILAGA_PASSWORD}\",\"http://pilaga/pilaga/rest/v1/\"]] 

# Kolla
store_secret_in_vault expedientes/data/${DIR_SECRETS}/kolla \
    PROYECTO_DB_PASSWORD=${POSTGRES_PASSWORD} \
    TOBA_DB_PASSWORD=${POSTGRES_PASSWORD} \
    API_BASIC_CLIENTES=[[\"${API_KOLLA_USERNAME}\",\"${API_KOLLA_PASSWORD}\"]]

# Mapuche
store_secret_in_vault expedientes/data/${DIR_SECRETS}/mapuche \
    PROYECTO_DB_PASSWORD=${POSTGRES_PASSWORD} \
    TOBA_DB_PASSWORD=${POSTGRES_PASSWORD} \
    API_BASIC_CLIENTES=[[\"${API_MAPUCHE_USERNAME}\",\"${API_MAPUCHE_PASSWORD}\"]] \
    DOCUMENTOS_CLAVE=${API_DOCS_PASSWORD} \
    CREDENCIALES_API_BASIC_REST_ARAI_USUARIOS=[[\"${API_USUARIOS_USERNAME}\",\"${API_USUARIOS_PASSWORD}\",\"http://usuarios-api/api/v1/\"]] \
    CREDENCIALES_API_BASIC_DIAGUITA=[[\"${API_DIAGUITA_USERNAME}\",\"${API_DIAGUITA_PASSWORD}\",\"http://diaguita/diaguita/rest/v1/\"]] \
    CREDENCIALES_API_BASIC_GUARANI=[[\"${API_GUARANI_USERNAME}\",\"${API_GUARANI_PASSWORD}\",\"http://guarani-gestion/gestion/rest/v1/\"]] \
    CREDENCIALES_API_BASIC_PILAGA=[[\"${API_PILAGA_USERNAME}\",\"${API_PILAGA_PASSWORD}\",\"http://pilaga/pilaga/rest/v1/\"]]

# Pilaga
store_secret_in_vault expedientes/data/${DIR_SECRETS}/pilaga \
    PROYECTO_DB_PASSWORD=${POSTGRES_PASSWORD} \
    TOBA_DB_PASSWORD=${POSTGRES_PASSWORD} \
    ARAI_PROV_DB_PASSWORD=${POSTGRES_PASSWORD} \
    API_BASIC_CLIENTES=[[\"${API_PILAGA_USERNAME}\",\"${API_PILAGA_PASSWORD}\"]] \
    DOCUMENTOS_CLAVE=${API_DOCS_PASSWORD} \
    CREDENCIALES_API_BASIC_REST_ARAI_USUARIOS=[[\"${API_USUARIOS_USERNAME}\",\"${API_USUARIOS_PASSWORD}\",\"http://usuarios-api/api/v1/\"]] \
    CREDENCIALES_API_BASIC_DIAGUITA=[[\"${API_DIAGUITA_USERNAME}\",\"${API_DIAGUITA_PASSWORD}\",\"http://diaguita/diaguita/rest/v1/\"]] \
    CREDENCIALES_API_BASIC_GUARANI=[[\"${API_GUARANI_USERNAME}\",\"${API_GUARANI_PASSWORD}\",\"http://guarani-gestion/guarani/gestion/rest/v1/\"]] \
    CREDENCIALES_API_BASIC_MAPUCHE=[[\"${API_MAPUCHE_USERNAME}\",\"${API_MAPUCHE_PASSWORD}\",\"http://mapuche/mapuche/rest/v1/\"]]

# Guarani
# Guarani-gestion
store_secret_in_vault expedientes/data/${DIR_SECRETS}/guarani-gestion \
    PROYECTO_DB_PASSWORD=${POSTGRES_PASSWORD} \
    TOBA_DB_PASSWORD=${POSTGRES_PASSWORD} \
    PREINSCRIPCION_DB_PASSWORD=${POSTGRES_PASSWORD} \
    API_BASIC_CLIENTES=[[\"${API_GUARANI_USERNAME}\",\"${API_GUARANI_PASSWORD}\"]] \
    DOCUMENTOS_CLAVE=${API_DOCS_PASSWORD} \
    CREDENCIALES_API_BASIC_ARAI_USUARIOS=[[\"${API_USUARIOS_USERNAME}\",\"${API_USUARIOS_PASSWORD}\",\"http://usuarios-api/api/v1/\"]] \
    CREDENCIALES_API_BASIC_KOLLA=[[\"${API_KOLLA_USERNAME}\",\"${API_KOLLA_PASSWORD}\",\"http://kolla/kolla/rest/\"]]

# Guarani-autogestion
store_secret_in_vault expedientes/data/${DIR_SECRETS}/guarani-autogestion \
    RDI_CLAVE=${NUXEO_PASSWORD} \
    GESTION_DB_PASSWORD=${POSTGRES_PASSWORD} \
    REST_GESTION_PASSWORD=${API_GUARANI_PASSWORD} \
    REST_ARAI_USUARIOS_PASSWORD=${API_USUARIOS_PASSWORD} \
    REST_KOLLA_PASSWORD=${API_KOLLA_PASSWORD} \
    DOCUMENTOS_CLAVE=${API_DOCS_PASSWORD}

# Guarani-preinscripcion
store_secret_in_vault expedientes/data/${DIR_SECRETS}/guarani-preinscripcion \
    RDI_CLAVE=${NUXEO_PASSWORD} \
    PREINSCRIPCION_DB_PASSWORD=${POSTGRES_PASSWORD} \
    GESTION_DB_PASSWORD=${POSTGRES_PASSWORD}
