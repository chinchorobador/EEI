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