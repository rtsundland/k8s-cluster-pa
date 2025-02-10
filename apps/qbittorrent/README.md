# qBittorrent

## VPN Prerequisites
Make sure to review the [Adding Tun VPN Support to Talos cluster](../README.md) section for configuration pre-requisites for the VPN.  There are Talos-specific configurations needed to enable the `tun` interface that will be used by `gluetun`.

## VPN Configuration
This VPN configuration specifically works with ProtonVPN using OpenVPN connectivity and qBittorrent.
* Configure the static port, e.g., 6881 (default in values.yaml)
* Get OpenVPN credentials from ProtonVPN
* Edit values.yaml with USERNAME and PASSWORD.  Make sure to append `+pmp` to the username to enable UPnP/NAT-PMP

## Install qBittorrent chart
```
kubectl create ns qbittorrent
kubectl apply -f qbittorrent.pv.yaml
kubectl apply -f qbittorrent.ingressroute.yaml
helm install -n qbittorrent qbittorrent oci://tccr.io/truecharts/qbittorrent -f values.yaml
```

## Configure qBittorrent

Within the qBittorrent configuration options UI (Tools > Operations)
1. Under the *Connection* tab
* Set `Peer Connection Protocol` to `TCP and uTP`
* Set `Port used for incoming connections` to the same value (default: 6881) from the previous section
* Check `Use UPnP/NAT-PMP port forwarding from my router`

2. Under the *Bittorrent* tab
* Uncheck `Enable DHT (decentralized network) to find more peers`
* Uncheck `Enable Peer Exchange (PeX) to find more peers`
* Uncheck `Enable Local Peer Discovery to find more peers`
* Set `Encryption Mode` to `Allow encryption`

3. Under the *Advanced* tb
* Set `Network Interface1 to `tun0`


