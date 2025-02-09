
## VPN Configuration
Make sure to review the README.md under apps/ for configuration pre-requisites for the VPN

> [!NOTE]
> Edit values.yaml to include your OpenVPN credentials to enable the tunnel before proceeding!!!!
>
```
kubectl create ns qbittorrent
kubectl apply -f qbittorrent.pv.yaml
kubectl apply -f qbittorrent.ingressroute.yaml
helm install -n qbittorrent qbittorrent oci://tccr.io/truecharts/qbittorrent -f values.yaml
```
