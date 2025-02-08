# Radarr4k

## Installation
```
kubectl create ns radarr4k
kubectl apply -f radarr4k.pv.yaml
helm install -n radarr4k radarr4k oci://tccr.io/truecharts/radarr4k -f values.yaml
kubectl -n radarr4k -f radarr4k.ingressroute.yaml
```

