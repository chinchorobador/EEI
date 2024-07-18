# EEI en Kubernetes

## Despliegue en Kubernetes

En la siguiente página encontrará las instrucciones necesarias para poder realizar un despliegue orquestrado con Kubernetes de las aplicaciones del ecosistema EEI. Esta guía además incluye una demo al principio para visualizar paso a paso los resultados de la misma.

:::note[**Nota**]

Tenga en cuenta que el objetivo de este instructivo es dejar funcionando un entorno de **desarrollo/test** con Kubernetes. Para sus entornos productivos, podrá utilizar la guía como referencia pero deberá adaptarla para satisfacer sus requisitos y necesidades, realizando todos los ajustes de configuración y seguridad que sean pertinentes. 

:::

#### Debajo encontrará la demo del despliegue en kubernetes:


<iframe width="560" height="315" src="https://www.youtube.com/embed/00A6RHKLuHU?si=_faE8oXSy7d7QZxv" title="Reproductor de Youtube: Canal SIU" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
*(Este video es de draft, hace falta todavía hacer la demo y grabarla cuando esté el resto terminado)*

## Requisitos previos

Partiendo de la base con que ya se cuenta con un cluster de kubernetes, los requisitos básicos para la gestión del mismo son los siguientes:

- **Kubectl** (se recomienda que la versión de cliente tenga una diferencia máxima de 1 version menor con respecto a la version del servidor).
- **Kustomize** v.5.3.0 (como mínimo). [Repositorio a releases](https://github.com/kubernetes-sigs/kustomize/releases)
- (Opcional): OpenLens como GUI para gestionar kubernetes

> Nota: Para facilitar la instalación de dependencias se puede utilizar [arkade](https://github.com/alexellis/arkade)



## Clonado del repositorio

El repositorio de deployments contiene un submodulo como repositorio base llamado [siu-k8s](https://gitlab.siu.edu.ar/devops/siu-k8s)

Para clonar simulanteamente tanto el repositorio de deployment como el submodulo debe ejecutarse el siguiente comando a la hora del git clone

```
git clone --recursive https://gitlab.siu.edu.ar/devops/k8s-deployments.git
```

En caso de tener problemas para pullear el submodulo por https, puede settearse la url por ssh con 

```
git submodule set-url siu-k8s git@gitlab.siu.edu.ar:devops/siu-k8s.git
```

## Estructura de proyecto

A continuación se presenta un diagrama como referencia de la estructura del proyecto:

<img src="https://i.imgur.com/TWyPSjH.png" alt="Diagrama de estructura del proyecto"></img>
[link al diagrama](https://i.imgur.com/TWyPSjH.png)

A la hora de trabajar localmente, el repositorio base (es decir, el submodulo [EEI-K8s](https://gitlab.siu.edu.ar/devops/eei-k8s)) **no se modifica directamente** ya que la estructura de dicha base se utiliza como template, el cuál se referenciará en los overlays con la herramienta **kustomize**.

En su lugar, se crean overlays que son copias de la carpeta `template/` parametrizado conforme a los requisitos de su instalación (TODO: CONTINUAR)

### Crear un Overlay Personalizado

Para crear un overlay personalizado primeramente hay que dirigirse a la ruta `template/scripts-init/` donde estará el script para poder generarlo.

```bash
cd template/scripts-init/
```

En segundo lugar es necesario generar los secrets de registry que es de donde luego se van a pullear las imágenes necesarias para el despliegue. Estos se deben crear del Gitlab/Hub respectivamente, hacer una copia de `registry-secrets.json.dist` y editar los valores necesarios:

```bash
cp registry-secrets.json.dist registry-secrets.json
vi registry-secrets.json
```

> Nota: Se recomienda utilizar tokens de acceso para ambos registries, con el fin de evitar guardar la contraseña de su usuario como texto plano en el `registry-secrets.json`

Como ultimo paso debe ejecutar el script `nuevo-overlay.sh`, proporcionando el nombre del overlay, el dominio y el namespace. Este script creará el overlay y configurará todos los secretos necesarios.

```bash
./nuevo-overlay.sh <nombre-del-overlay> <dominio> <namespace>
```

por ejemplo

```bash
./nuevo-overlay.sh universidad universidad.edu.ar template-universidad
```

Este script se encargará de realizar las siguientes tareas:

- Crear la estructura del overlay.
- Configurar el dominio especificado.
- Configurar el namespace especificado.
- Generar y configurar todos los secrets necesarios para el despliegue.

> Nota: Después de ejecutar el script, si necesita realizar alguna personalización adicional en los secrets generados, puede editar los archivos en `<nombre-del-overlay>/secrets` según sea necesario.

## Secrets

Aplicar los secrets:

```bash
kubectl apply -k <nombre-del-overlay>/secrets
```
:::warning[**Advertencia**]

Notese que el `.gitignore` del proyecto está excluyendo los siguientes directorios

```
**/secrets/**
!template/secrets/**
!template-vault/secrets/**
```

Asegurese que los secrets que haya creado para su overlay no sean commiteados dentro de su repositorio para evitar filtraciones de los mismos.

:::

## Configuracion servicios basicos

> Nota: en este punto debemos estar parados nuevamente en el root del proyecto para realizar todos los despliegues.

### Despliegue de postgres, ldap, minio.

> Nota: Es importante destacar que estos despliegues están diseñados exclusivamente para pruebas o desarrollo, y no se recomiendan para entornos de producción. 
La infraestructura se implementa utilizando Kubernetes en lugar de en entornos locales (on-premise).

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/services/postgres | kubectl apply -f -
kustomize build --load-restrictor LoadRestrictionsNone universidad/services/ldap | kubectl apply -f -
kustomize build --load-restrictor LoadRestrictionsNone universidad/services/minio | kubectl apply -f -
```

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

Con el siguiente comando se procede a crear la base, se crea el admin, se inicializa las personas (se queda esperando a que este levantado personas para proseguir) y usuarios-inicializar-recursos.yaml

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/jobs/usuarios/init | kubectl apply -f -
```

Por último deberá ejecutar este job, el cual se encarga de configurar las apps dentro de usuarios. Con la misma idea se podría agregar las aplicaciones de otros módulos, lo único que debemos hacer es dentro de `universidad/jobs/usuarios/config-apps` agregar el json correspondiente, eliminar el job y volverlo a correr.

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/jobs/usuarios/config-apps | kubectl apply -f -
```

Una vez realizados estos pasos, debería poder acceder en https://universidad.edu.ar/usuarios (o el dominio que haya definido)

## Configuracion y despliegue de Araí-Personas

La especificación de los servicios de este módulo se encuentra en `base-siu/personas` dentro de este tendremos el archivo `peronas-api.yaml`

Existen tambien otro archivo de configuración asociado en: `universidad/apps/personas/config/personas-api.env` 

### Acceso a Postgres

Crear la base de datos como recurso externo, recordar que la configuración para la misma se debe incluir en el secret `template/eei-secrets/personas-secret.env` y también en el archivo `universidad/apps/personas/config/personas-api.env`.env

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

Por último debe ejecutar el job el cual genera la base de datos de personas y en este punto es donde el job corrido anteriormente en usuarios (usuarios-inicializar-personas.yml) inicializa las personas, impacta y se ejecuta.

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/jobs/personas/init | kubectl apply -f -
```

## Configuracion y despliegue de SIU-Huarpe

La especificación de los servicios de este módulo se encuentra en `base-siu/huarpe` dentro de este tendremos dos archivos `huarpe.yaml` y `huarpe-memcached.yaml`. 

Existen tambien otro archivo de configuración asociado en: `universidad/apps/huarpe/config/huarpe.env`.

```bash 
kustomize build --load-restrictor LoadRestrictionsNone universidad/apps/huarpe | kubectl apply -f -
```


## Configuracion y despliegue de arai-documentos

La especificación de los servicios de este módulo se encuentra en `base-siu/documentos` dentro de este tendremos dos archivos `docs-api.yaml` y `docs-worker.yaml`

Existen tambien otro archivo de configuración asociado en: `universidad/apps/documentos/config/docs.env` este se puede editar tomando como referencia el que estan en base-siu/documentos/config

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

### Stamper

La especificación del servicio de este módulo se encuentra en `base-siu/estampador` dentrode este tendremos los archivos pertinentes del modulo

Existe tambien otro archivo de configuración asociados en universidad/apps/estampador/config: `docs-stamper.env`.

Una vez tenga el Keystore debe editar la configuracion en `universidad/apps/estampador/config/docs.stamper.env`

Una vez que se tenga posesión de la keystore a utilizar ejecute el siguiente comando para generar el nuevo secreto.

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/apps/estampador | kubectl apply -f -
```

> Nota: El ambiente se inicia con uno stamper de prueba (autofirmado) ubicado en `base-siu/estampador/secrets`. Si dispone de un keystore personalizado, puede reemplazarlo en esta ruta y ademas debe cambiar la clave en `universidad/secrets/docs-stamper-secrets.env` en y asi utilizarlo sin problemas. También puede directamente desactivar el stamper, esto se puede hacer desde

## Habilitar acceso externo de API´s

Por defecto, las API se encuentran expuestas en el rango 127.0.0.1/32. Es necesario reemplazar por los rangos autorizados para acceder al servicio. Este paso es de suma importancia para garantizar la seguridad del sistema.

Para llevar a cabo esta configuración, se debe editar el archivo [overlays/devops/common/ingress/kustomization.yaml](https://gitlab.siu.edu.ar/devops/siu-k8s/-/blob/main/overlays/devops/common/ingress/kustomization.yaml?ref_type=heads). En la sección `value` de este archivo, se encuentra el rango a cambiar, mientras que en  la seccion `name`se encuentran todos los nombres de ingress que se va whitelistear.

## Configuracion y despliegue de Sudocu

La especificación de los servicios de este módulo se encuentra en `base-siu/sudocu` dentro de este tendremos los archivos pertinentes del modulo

Existen tambien otros archivos de configuración asociados en universidad/apps/sudocu/config: `config-api-server.json`, `config-sudocu-gestion.json`, `config-sudocu-mpd.json`, `config-sudocu-mpc.json`, `config-sudocu-login.json`.

### Acceso a Postgres

Editar la configuracion de conexión a la base de datos en el archivo `universidad/apps/sudocu/config/config-api-server.json`:

```
  "ungsxt": {
    "host": "db-sudocu",
    "port": "5432",
    "database": "sudocu",
    "user": "postgres"
  }
```

Luego debe proceder a realizar el deploy del init el cual procederá a crear la base

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/jobs/sudocu/init | kubectl apply -f -
```

### Despliegue de aplicación

Una vez realizado lo anterior ya podemos desplegar todos los servicios correspondientes para el funcionamiento de sudocu (sudocu-api-server, sudocu-api-worker, sudocu-cache, sudocu-files-pvc, sudocu-gestion, sudocu-login, sudocu-mpc, sudocu-mpd, sudocu-pdf) con el siguiente comando.

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/apps/sudocu | kubectl apply -f -
```

## Crear usuario Admin de Sudocu en Araí Usuarios
1. Ingrese a Araí-Usuarios (user `admin` y password seteado [anteriormente](arai.md#bootstraping-del-proyecto))
1. Dirigirse al item Usuarios
1. Presionar el botón `Agregar +`
1. Completar de la siguiente manera el tab `Perfil`:
   * Identificador: adminsudocu
   * Nombre: Admin
   * Apellido: Sudocu
   * Nombre: Admin
   * E-mail: admin@sudocu.edu.ar
   * Password: ******
1. Presionar el botón `Guardar`
1. Completar de la siguiente manera el tab `Cuentas`
   * Aplicación: Sudocu
   * Cuenta: adminsudocu
1. Presionar el botón `Agregar`
1. Presionar el botón `Guardar`



> Una vez realizados estos pasos, debería poder acceder en https://universidad.edu.ar/sudocu (o el dominio que haya definido)

Para mayor información y documentación funcional recurrir a la [página oficial de SUDOCU](https://sudocu.dev).