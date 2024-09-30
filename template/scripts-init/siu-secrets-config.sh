#!/bin/bash

generar_secrets(){
    mkdir -p ${SECRETS_DIR}

    PWDGEN="cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1"

    export POSTGRES_USERNAME=postgres
    export POSTGRES_PASSWORD=$(eval ${PWDGEN})

    export LDAP_ADMIN_PASSWORD=$(eval ${PWDGEN})
    export LDAP_CONFIG_PASSWORD=$(eval ${PWDGEN})

    export MINIO_USERNAME=minio
    export MINIO_PASSWORD=$(eval ${PWDGEN})

    export NUXEO_USERNAME=Administrator
    export NUXEO_PASSWORD=$(eval ${PWDGEN})

    # export DOCS_DB_USERNAME=documentos
    # export DOCS_DB_PASSWORD=$(eval ${PWDGEN})
    # export PERSONAS_DB_USERNAME=personas
    # export PERSONAS_DB_PASSWORD=$(eval ${PWDGEN})
    # export USUARIOS_DB_USERNAME=usuarios
    # export USUARIOS_DB_PASSWORD=$(eval ${PWDGEN})
    # export SUDOCU_DB_USERNAME=sudocu
    # export SUDOCU_DB_PASSWORD=$(eval ${PWDGEN})
    export DOCS_DB_USERNAME=${POSTGRES_USERNAME}
    export DOCS_DB_PASSWORD=${POSTGRES_PASSWORD}
    export PERSONAS_DB_USERNAME=${POSTGRES_USERNAME}
    export PERSONAS_DB_PASSWORD=${POSTGRES_PASSWORD}
    export USUARIOS_DB_USERNAME=${POSTGRES_USERNAME}
    export USUARIOS_DB_PASSWORD=${POSTGRES_PASSWORD}
    export SUDOCU_DB_USERNAME=${POSTGRES_USERNAME}
    export SUDOCU_DB_PASSWORD=${POSTGRES_PASSWORD}

    export DIAGUITA_DB_USERNAME=${POSTGRES_USERNAME}
    export DIAGUITA_DB_PASSWORD=${POSTGRES_PASSWORD}
    export GUARANI_GESTION_DB_USERNAME=${POSTGRES_USERNAME}
    export GUARANI_GESTION_DB_PASSWORD=${POSTGRES_PASSWORD}
    export GUARANI_PREINSCRIPCION_DB_USERNAME=${POSTGRES_USERNAME}
    export GUARANI_PREINSCRIPCION_DB_PASSWORD=${POSTGRES_PASSWORD}
    export KOLLA_DB_USERNAME=${POSTGRES_USERNAME}
    export KOLLA_DB_PASSWORD=${POSTGRES_PASSWORD}
    export MAPUCHE_DB_USERNAME=${POSTGRES_USERNAME}
    export MAPUCHE_DB_PASSWORD=${POSTGRES_PASSWORD}
    export PILAGA_DB_USERNAME=${POSTGRES_USERNAME}
    export PILAGA_DB_PASSWORD=${POSTGRES_PASSWORD}
    export PROVEEDORES_DB_USERNAME=${POSTGRES_USERNAME}
    export PROVEEDORES_DB_PASSWORD=${POSTGRES_PASSWORD}

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

    export RECAPTCHA_SITIO_PASSWORD=6LeIxAcTAAAGETMEFROMRECAPTCHASITE
    export RECAPTCHA_CLAVE_PASSWORD=6LeIxAcTAAAAAGG-GETMEFROMWEBBEFORE

    export NOTIFICACIONES_DB_PASSWORD=${POSTGRES_PASSWORD}
    export API_NOTIFICACIONES_USERNAME=proveedores
    export API_NOTIFICACIONES_PASSWORD=$(eval ${PWDGEN})
    export NOTIFICACIONES_MAILER_DSN_SEGURO=smtp://user:pass@mailer

    export PROVEEDORES_DB_PASSWORD=${POSTGRES_PASSWORD}
    export API_PREINSCRIPCION_PASSWORD=token123

    # export DOCS_STAMPER_KEYSTORE_PASS=$(eval ${PWDGEN})
    export DOCS_STAMPER_KEYSTORE_PASS=1234
    # Crear el keystore para el stamper usando mkcert y openssl
    # Paso 1: Crear certificado para uunn.local con mkcert
    # mkcert uunn.local *.uunn.local
    # Paso 2: Generar keystore para el stamper
    # openssl pkcs12 -export -out ${SECRETS_DIR}/keystore_stamper.p12 -inkey uunn.local-key.pem -in uunn.local.pem -name "KeyStamper" -password pass:1234

    # Se mantienen los valores de los secrets ya generados
    if [ -f ${SECRETS_DIR}/secrets.env ]; then
        source ${SECRETS_DIR}/secrets.env
    fi
    env | sort > ${SECRETS_DIR}/secrets.env

    if [ ! -d "../../siu-k8s/template/secrets" ]; then
        echo -e "\nNo se encontró el directorio ../../siu-k8s/template/secrets, recuerde tener actualizado el submodulo siu-k8s."
        exit 1
    else
        ls ../../siu-k8s/template/secrets | while read CFG; do
            if [ ! -f ${SECRETS_DIR}/${CFG} ]; then
                cat ../../siu-k8s/template/secrets/${CFG} | envsubst > ${SECRETS_DIR}/${CFG}
            fi
        done

    fi

}