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

Partiendo de la base con que **ya se cuenta con un cluster de kubernetes**, los requisitos básicos para la gestión del mismo son los siguientes:

- **Kubectl** (se recomienda que la versión de cliente tenga una diferencia máxima de 1 version menor con respecto a la version del servidor). [Documentación oficial](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- **Kustomize** v.5.3.0 (como mínimo). [Documentación oficial](https://kubectl.docs.kubernetes.io/installation/kustomize/)
- (Opcional): OpenLens como GUI para gestionar kubernetes



## Clonado del repositorio

El repositorio de deployments contiene un submodulo como repositorio base llamado [siu-k8s](https://gitlab.siu.edu.ar/devops/siu-k8s)

Para clonar simulanteamente tanto el repositorio de deployment como el submodulo debe ejecutarse el siguiente comando a la hora del git clone

```
git clone --recursive https://gitlab.siu.edu.ar/devops/k8s-deployments.git
```

Si ya tiene clonado el repositorio pero tiene problemas para clonar el submodulo, puede especificar qué método especifico usar para clonarlo (ya sea HTTPS o SSH) con los siguientes comandos 

> Clonado por HTTPS
```
git submodule set-url siu-k8s https://gitlab.siu.edu.ar/devops/siu-k8s.git
```

>Clonado por SSH

```
git submodule set-url siu-k8s git@gitlab.siu.edu.ar:devops/siu-k8s.git
```

## Actualización de submodulo

Si usted ya tiene clonado el repositorio y desea actualizar el submodulo siu-k8s, puede hacerlo con el siguiente comando

```
git submodule update --init --recursive
```



## Estructura de proyecto

A continuación se presenta un diagrama como referencia de la estructura del proyecto:

<img src="https://i.imgur.com/IIGTEtj.png" alt="Diagrama de estructura del proyecto"></img>
[link al diagrama](https://i.imgur.com/IIGTEtj.png)

A la hora de trabajar localmente, el repositorio base (es decir, el submodulo [EEI-K8s](https://gitlab.siu.edu.ar/devops/eei-k8s)) **no se modifica directamente** ya que la estructura de dicha base se utiliza como template, el cuál se referenciará en los overlays con la herramienta **kustomize**.

En su lugar, se crean overlays que son copias de la carpeta `template/` parametrizado conforme a los requisitos de su instalación.

### Crear un namespace para su cluster

El formato de template actual propone el despliegue de las aplicaciones SIU (y sus dependencias) dentro de un **único** namespace. Notese que éste requerimiento **no es excluyente, pero necesario** para desplegar los servicios de la manera indicada en esta documentación.

Para crear el namespace en el cluster al cual está conectado, utilice el siguiente comando

```bash
kubectl create namespace <namespace>
```

por ejemplo

```bash
kubectl create namespace template-universidad
```

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

Antes de aplicar los secrets, dirijase a la raíz del proyecto nuevamente para facilitar los pasos posteriores

```bash
cd ../..
```

Una vez parado en la raíz del proyecto, Aplicar los secrets:

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

### Despliegue de Postgresql, Ldap, Minio.

> Nota: Es importante destacar que estos despliegues están diseñados exclusivamente para pruebas o desarrollo, y no se recomiendan para entornos de producción. 

La infraestructura se implementa utilizando pods de Kubernetes en lugar de binarios on-premise. Debido a esto, para desplegar los servicios debe ejecutar los siguientes comandos:

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

Con el siguiente comando se procede a crear la base, se crea el admin, se inicializa las personas (se queda esperando a que este levantado personas para proseguir) y `usuarios-inicializar-recursos.yaml`

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/jobs/usuarios/init | kubectl apply -f -
```

Por último deberá ejecutar este job, el cual se encarga de configurar las apps (junto a sus urls y parametros de SAML) dentro de Arai-Usuarios. 

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/jobs/usuarios/config-apps | kubectl apply -f -
```

> Nota: De desearlo, es posible agregar service providers extras en arai-usuarios, para esto debe guardar un .json con los datos generales y de SAML de la aplicación, además de un icono para la misma, dentro de `universidad/jobs/usuarios/config-apps`. Luego debe reflejar estos archivos en el `universidad/jobs/usuarios/config-apps/aplicaciones/kustomization.yaml`, eliminar el job y volverlo a correr.

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

## Configuracion y despliegue de Sudocu

La especificación de los servicios de este módulo se encuentra en `base-siu/sudocu` dentro de este tendremos los archivos pertinentes del modulo

Existen tambien otros archivos de configuración asociados en universidad/apps/sudocu/config: `config-api-server.json`, `config-sudocu-gestion.json`, `config-sudocu-mpd.json`, `config-sudocu-mpc.json`, `config-sudocu-login.json`.

### Acceso a Postgres

Para configurar la conexión de sudocu con el servidor postgres, verifique que los datos de la configuración ubicados en el archivo `universidad/apps/sudocu/config/config-api-server.json` sean los correctos:

```
  "ungsxt": {
    "host": "db-siu",
    "port": "5432",
    "database": "sudocu",
    "user": "postgres"
  }
```

> Nota: El parametro host `db-siu` hace referencia al pod de postgres desplegado con este repositorio. Si precisa conectarlo con otra instancia de postgres que ya tiene desplegada, o con una instancia de postgres en otro namespace, recuerde ajustar este parametro. 

Luego debe proceder a realizar el deploy del init el cual procederá a crear la base

@TODO: ver en que partes hacer la aclaración sobre el host db-siu en toda la documentación.

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/jobs/sudocu/init | kubectl apply -f -
```

### Despliegue de aplicación

Una vez realizado lo anterior ya podemos desplegar todos los servicios correspondientes para el funcionamiento de sudocu (sudocu-api-server, sudocu-api-worker, sudocu-cache, sudocu-files-pvc, sudocu-gestion, sudocu-login, sudocu-mpc, sudocu-mpd, sudocu-pdf) con el siguiente comando.

```bash
kustomize build --load-restrictor LoadRestrictionsNone universidad/apps/sudocu | kubectl apply -f -
```

### Crear usuario Admin de Sudocu en Araí Usuarios
1. Ingrese a Araí-Usuarios con la credencial de administrador (password setteado en `universidad/secrets/usuarios-secrets.env`)
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

## Habilitar acceso externo de APIs

Por defecto, las APIs se encuentran expuestas en el rango `127.0.0.1/32`, es decir que no se pueden acceder externamente. De requerirlo, puede habilitar otros rangos de su red para acceder a las APIs del servicio necesario. 

Para llevar a cabo esta configuración, se debe editar el archivo `universidad/common/ingress/kustomization.yaml`. En la sección `value` de este archivo, se encuentra el rango a cambiar, mientras que en la seccion `name` se encuentran todos los nombres de ingress que se va whitelistear.

Recuerde que para aplicar estos cambios, **debe volver a desplegar cada uno de los servicios cuyas APIs se ven impactadas.**

## Personalización de la arquitectura

En la arquitectura de este despliegue se optó por utilizar `nginx` como proveedor de ingress y `longhorn` como storage class, pero en base a sus requerimientos es posible optar por otros servicios para estas soluciones (ej: traefik como ingress y TrueNAS como storage). Tenga en cuenta que para esto, deberá realizar modificaciones en los siguientes archivos, acompañandose de la documentación del proveedor elegido:


#### Ingress

`/common/ingress/kustomization.yaml`

#### Storage Class

`/common/pvc/kustomization.yaml`

Lectura sugerida sobre storage classes e ingress: 

- https://kubernetes.io/docs/concepts/storage/storage-classes/

- https://www.kubecost.com/kubernetes-best-practices/kubernetes-storage-class/

- https://kubernetes.io/docs/concepts/services-networking/ingress/

- https://amazic.com/list-of-the-top-ingress-controllers-for-kubernetes/

- https://www.solo.io/topics/kubernetes-api-gateway/kubernetes-ingress/