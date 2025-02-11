# Radarr

## Installation
```
kubectl create ns radarr
kubectl apply -f radarr.pv.yaml
helm install -n radarr radarr oci://tccr.io/truecharts/radarr -f values.yaml
kubectl apply -f radarr.ingressroute.yaml
```

