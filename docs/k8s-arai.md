## Configuracion y despliegue de Araí-Usuarios

La especificación de los servicios de este módulo se encuentra en `base-siu/usuarios` dentro de este tendremos estos archivos `usuarios-api.yaml`, `usuarios-idm.yaml`, `usuarios-idp.yaml`, `usuarios-memcached.yaml` y `usuarios-resource-pvc.yaml`

Existe tambien otro archivo de configuración asociado en: `universidad/apps/usuarios/config/usuarios.env`

### Acceso a Postgres y LDAP

Los parámetros de conexión los puede encontrar en el archivo `universidad/apps/usuarios/config/usuarios.env`, y son los siguientes:

```
###### CONFIG DB ######
DB_HOST=db-siu
DB_PORT=5432
DB_DBNAME=usuarios
DB_USERNAME=postgres
DB_SCHEMA=usuarios

##### CONFIG LDAP #####
LDAP_HOST=ldap
LDAP_PORT=389
LDAP_TLS=0
LDAP_METHOD=user
LDAP_BINDUSER=cn=admin,dc=siu,dc=cin,dc=edu
LDAP_BINDPASS_FILE=/run/secrets/usuarios_ldap_admin_pass
LDAP_SEARCHBASE=dc=siu,dc=cin,dc=edu
LDAP_USERS_OU=usuarios
LDAP_USERS_ATTR=ou
LDAP_ACCOUNTS_OU=usuariosCuentas
LDAP_ACCOUNTS_ATTR=ou
LDAP_GROUPS_OU=groups
LDAP_GROUPS_ATTR=ou
LDAP_NODES=
```

### Despliegue de aplicación 

A continuación deberá proceder a realizar el despliegue de los módulos de la aplicación:

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/apps/usuarios | kubectl apply -f -
```

Con el siguiente comando se procede a crear la base, se crea el admin, se inicializa las personas (se queda esperando a que este levantado personas para proseguir) y `usuarios-inicializar-recursos.yaml`

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/jobs/usuarios/init | kubectl apply -f -
```

Por último deberá ejecutar este job, el cual se encarga de configurar las apps (junto a sus urls y parametros de SAML) dentro de Arai-Usuarios. 

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/jobs/usuarios/config-apps | kubectl apply -f -
```

> Nota: De desearlo, es posible agregar aplicaciones adicionales, lo único que debe hacer es agregar el .json correspondiente y el icono de la aplicación dentro de `universidad/jobs/usuarios/config-apps`, eliminar el job y volverlo a correr.

Una vez realizados estos pasos, debería poder acceder en https://universidad.edu.ar/usuarios (o el dominio que haya definido).

## Configuracion y despliegue de Araí-Personas

La especificación de los servicios de este módulo se encuentra en `base-siu/personas` dentro de este tendremos el archivo `peronas-api.yaml`

Existen tambien otro archivo de configuración asociado en: `universidad/apps/personas/config/personas-api.env` 

### Acceso a Postgres

Crear la base de datos como recurso externo, recordar que la configuración para la misma se debe incluir en el secret `universidad/secrets/personas-secret.env` y también en el archivo `universidad/apps/personas/config/personas-api.env`.env

```
###### CONFIG DE LA BASE DE NEGOCIO ######
DB_HOST=db-siu
DB_PORT=5432
DB_DBNAME=arai_personas
DB_USERNAME=postgres
DB_PASSWORD_FILE=/var/secrets/DB_PASSWORD
DB_SCHEMA=personas
DB_ENCODING=UTF8

```
### Despliegue de aplicación 

A continuación deberá proceder a realizar el despliegue de los módulos de la aplicación:

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/apps/personas | kubectl apply -f -
```

Por último debe ejecutar el job el cual genera la base de datos de personas y en este punto es donde el job corrido anteriormente en usuarios (`usuarios-inicializar-personas.yml`) inicializa las personas, impacta y se ejecuta.

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/jobs/personas/init | kubectl apply -f -
```

## Configuracion y despliegue de SIU-Huarpe

La especificación de los servicios de este módulo se encuentra en `base-siu/huarpe` dentro de este tendremos dos archivos `huarpe.yaml` y `huarpe-memcached.yaml`. 

Existen tambien otro archivo de configuración asociado en: `universidad/apps/huarpe/config/huarpe.env`.

### Despliegue de aplicación

```bash 
kustomize build --load-restrictor LoadRestrictionsNone universidad/apps/huarpe | kubectl apply -f -
```


## Configuracion y despliegue de Arai-Documentos

La especificación de los servicios de este módulo se encuentra en `base-siu/documentos` dentro de este tendremos dos archivos `docs-api.yaml` y `docs-worker.yaml`

Existen tambien otro archivo de configuración asociado en: `universidad/apps/documentos/config/docs.env` este se puede editar tomando como referencia el que estan en `base-siu/documentos/config`

### Acceso a Postgres

Editar la configuracion de conexión a la base de datos en el archivo `universidad/apps/config/docs.env`:

```
###### CONFIG DE LA BASE DE NEGOCIO ######
ARAI_DOCS_DB_HOST=db-siu
ARAI_DOCS_DB_PORT=5432
ARAI_DOCS_DB_DBNAME=arai_documentos
ARAI_DOCS_DB_USERNAME=postgres
```

### Conexión con Nuxeo o MinIO

Dependiendo de la solución que haya elegido utilizar, debe ajustar las variables de entorno según corresponda:

```
# S3 / MINIO
ARAI_DOCS_S3_ENDPOINT=http://minio:9000
ARAI_DOCS_S3_KEY=minio
ARAI_DOCS_S3_REGION=us-east-1
ARAI_DOCS_S3_BUCKET=documentos
ARAI_DOCS_S3_VERSION=latest

# NUXEO
ARAI_DOCS_NUXEO_HOST=http://url-servicio-nuxeo:8080/nuxeo/atom/cmis/
ARAI_DOCS_NUXEO_USUARIO=Administrator
ARAI_DOCS_NUXEO_CLAVE_FILE=/var/secrets/ARAI_DOCS_NUXEO_CLAVE
```

### Despliegue de aplicación

Una vez finalizado lo anterior ya podemos desplegar todos los servicios correspondientes a documentos:

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/apps/documentos | kubectl apply -f -
```

Por último debe ejecutar el job el cual genera la base de datos de documentos.

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/jobs/documentos/init | kubectl apply -f -
```

## Configuracion y despliegue de Stamper 

> Nota: 
En caso de no necesitar el estampador, puede desactivarlo modificando la variable `STAMPER_ACTIVO` y `STAMPER_SELLOS_ACTIVO` ubicadas en `universidad/apps/documentos/config/docs.env`. Una vez hecho esto, puede continuar con el despliegue del resto de servicios.

La especificación del servicio de este módulo se encuentra en `base-siu/estampador`, dentro de este tendremos los archivos pertinentes del aplicativo

Existe tambien otro archivo de configuración en el overlay ubicado en `universidad/apps/estampador/config/docs-stamper.env`.

Este servicio se encuentra **activado por defecto**, y requiere de la disposición de un keystore para el funcionamiento del mismo.

> Nota: Para la creación de este, dirigirse a la siguiente [guia](https://documentacion.siu.edu.ar/documentos/docs/next/firma-sistema/)

### Despliegue de aplicación

Una vez que posea el Keystore, debe: 

- 1) Ubicar el archivo .p12 en el directorio `<nombre-del-overlay>/secrets`
- 2) Verificar que los parametros del archivo de configuracion `universidad/apps/estampador/config/docs.stamper.env` correspondan a los creados para su keystore.
- 3) Verificar que la clave `ARAI_DOCS_STAMPER_KEYSTORE_PASS` ubicada en el archivo `universidad/secrets/docs-stamper-secrets.env` coincida con la de su keystore.

Una vez cumplido dichos requisitos, ejecute el siguiente comando para desplegar el servicio de estampador:

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/apps/estampador | kubectl apply -f -
```

## Habilitar acceso externo de APIs

Por defecto, las APIs se encuentran expuestas en el rango `127.0.0.1/32`, es decir que no se pueden acceder externamente. De requerirlo, puede habilitar otros rangos de su red para acceder a las APIs del servicio necesario. 

Para llevar a cabo esta configuración, se debe editar el archivo `universidad/common/ingress/kustomization.yaml`. En la sección `value` de este archivo, se encuentra el rango a cambiar, mientras que en la seccion `name` se encuentran todos los nombres de ingress que se va whitelistear.

Recuerde que para aplicar estos cambios, **debe volver a desplegar cada uno de los servicios cuyas APIs se ven impactadas.**