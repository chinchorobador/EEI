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