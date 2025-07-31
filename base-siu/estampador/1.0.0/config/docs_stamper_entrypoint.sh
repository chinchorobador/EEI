#!/bin/bash

apk update

# Se instala tzdata para configurar la zona horaria. Se realiza desde variables de entorno
apk add --no-cache \
    tzdata
    # java-cacerts \

# Se agrega el certificado al repositorio de las CA (para que se puedan utilizar certificados autofirmados)
# apk add --update --no-cache --allow-untrusted \
#     --repository=http://dl-cdn.alpinelinux.org/alpine/v3.17/main \
#     ca-certificates=20230506-r0
# ln -sf /etc/ssl/certs/java/cacerts ${JAVA_HOME}/lib/security/cacerts
# keytool -exportcert -alias ${ARAI_DOCS_STAMPER_KEYSTORE_ALIAS} -rfc -keystore /app/classes/config/${ARAI_DOCS_STAMPER_KEYSTORE} -storepass ${ARAI_DOCS_STAMPER_KEYSTORE_PASS} -file /usr/local/share/ca-certificates/keystore_stamper.crt
# cat /usr/local/share/ca-certificates/keystore_stamper.crt
# update-ca-certificates
# # update-ca-certificates --fresh

java \
    -Xms${JAVA_XMS:=512}m \
    -Xdebug \
    -cp /app/resources:/app/classes:/app/libs/* \
    ar.com.nomi.necro.estampatodo.Application
    # -Djavax.net.ssl.trustStore=/app/classes/config/${ARAI_DOCS_STAMPER_KEYSTORE} \
    # -Djavax.net.ssl.trustStorePassword=${ARAI_DOCS_STAMPER_KEYSTORE_PASS} \
