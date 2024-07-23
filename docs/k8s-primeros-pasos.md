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
