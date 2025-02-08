# Application Configurations

## Adding Ingress
Since we're using Traefik, we will use IngressRoute CRDs.  This was decided since different packages/charts appear to use slightly different syntaxes, and 
I would like to leverage some of the more flexible routing options available in IngressRute.

Here's an example of an IngressRoute for Plex
```
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: plex
  namespace: plex
spec:
  entryPoints:
    - web
    - websecure
  routes:
    - kind: Rule
      match: Host(`plex.apps.home.sundland.net`) && PathPrefix(`/`)
      services:
        - name: plex-plex-media-server
          namespace: plex
          port: 32400
          scheme: http
  tls: { }
```

## Exposing Service via LoadBalancer

## Adding Persistence (volumes)
Pending

```
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: plex-config
  namespace: plex
spec:
  storageClassName: kenobi-replicated
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20G
```

## Scheduling Backups
Pending


