# Application Configurations

## Adding Tun Support to Talos cluster

### Installing the DaemonSet for access to tun interface
Per the URLs below, this chart neeeded to enable tun interfaces on Talos Linux.  This will enable the tun interface on the cluster.  We'll install it on the default namespace.
```
kubectl apply -f generic-device-plugin.yaml
```

You can verify the tun interface by running:
```
kubectl describe node <worker-node> 
```
And looking for
```
...
Allocated resources:
  Resource           Requests     Limits
  --------           --------     ------
  ...
  squat.ai/tun       0            0
```

### Configure namespace to use the tun interface
Special label needs to be applied to the namespace to use the tun interface:
```
kubectl label --overwrite ns <namespacee> pod-security.kubernetes.io/enforce=privileged
```

### Configure pod/deployment to use the tun interface
For deployments that require use of the tun interface, add the following to ... the pod resource spec (helm values.yaml?)
```
resources:
  limits:
    squat.ai/tun: "1"
```

### Documentation
https://www.talos.dev/v1.9/kubernetes-guides/configuration/device-plugins/

https://truecharts.org/guides/vpn-setup/

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
apiVersion: v1
kind: PersistentVolumeClaim
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

## Scheduling Snapshots
See the [snapshotscheduler README](../snapshotscheduler/README.md)

## Scheduling Backups
Pending


