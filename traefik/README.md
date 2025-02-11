# Installing Traefik

## Source Documentation
https://truecharts.org/charts/system/traefik-crds/

https://truecharts.org/charts/premium/traefik/

## Background
This is a chart from the Truecharts project.

## Create Namespace
```
kubectl create ns tc-traefik
```

## Install Traefik CRDs
```
helm install -n tc-traefik traefik-crds oci://tccr.io/truecharts/traefik-crds
```

## Install Traefik
Using our custom values.yaml, we're going to assign the default certificate and choose a specific address pool and IP address from that pool
```
helm install -n tc-traefik traefik oci://tccr.io/truecharts/traefik -f values.yaml
```

## Check Traefik Services
```
kubectl get svc -n tc-traefik
```
Output
```
NAME              TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
traefik           ClusterIP      10.107.232.184   <none>        9000/TCP                     9h
traefik-metrics   ClusterIP      10.103.209.81    <none>        9180/TCP                     9h
traefik-tcp       LoadBalancer   10.103.203.158   10.6.64.70    80:32372/TCP,443:32726/TCP   9h
```

# Traefik IngressClass
We will need to manually create a default ingressClass for Traefik to be used to define ingressRoutes
```
kubectl -n tc-traefik apply -f traefik.ingressclass.yaml
```

## Create an ingress for the dashboard
We will not create an ingressRoute for the traefik internal dashboard.  This will replace the one created by the helm chart, but that's ok.
```
kubectl -n tc-traefik apply -f traefik-dashboard.ingressroute.yaml
```

