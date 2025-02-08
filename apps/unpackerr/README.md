# Unpackerr

## Installation
```
kubectl create ns unpackerr
kubectl apply -f unpackerr.pv.yaml
helm install -n unpackerr unpackerr oci://tccr.io/truecharts/unpackerr -f values.yaml
```

