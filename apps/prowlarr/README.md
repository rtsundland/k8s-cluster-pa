# Prowlarr

## Installation
Prowlarr installation is fairly simple, we will create a persistent PV ahead of time
```
kubectl create ns prowlarr
kubectl apply f prowlarr.pv.yaml
helm install -n prowlarr prowlarr oci://tccr.io/truecharts/prowlarr -f values.yaml
kubectl -n prowlarr -f prowlarr.ingressroute.yaml
```

