# Sonarr

## Installation
```
kubectl create ns sonarr
kubectl apply -f sonarr.pv.yaml
helm install -n sonarr sonarr oci://tccr.io/truecharts/sonarr -f values.yaml
kubectl -n sonarr -f sonarr.ingressroute.yaml
```

