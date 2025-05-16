# Radarr4k

## Installation
```
kubectl create ns radarr4k
kubectl apply -f radarr4k.pv.yaml
helm upgrade --install -n radarr4k radarr4k oci://tccr.io/truecharts/radarr -f values.yaml
kubectl apply -f radarr4k.ingressroute.yaml
```

