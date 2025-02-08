# Flaresolverr

## Installation
Flaresolverr will get installed in the same namespace as prowlarr, so create prowlarr first
```
kubectl apply -f flaresolverr.pv.yaml
helm install -n prowlarr flaresolverr oci://tccr.io/truecharts/flaresolverr -f values.yaml
```
> [!NOTE]
> Flaresolverr does not require an IngressRoute
