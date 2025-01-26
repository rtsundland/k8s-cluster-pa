# Talos Cluster (talos-pa)

This cluster is built using TrueNAS virtual machines using the base metal Talos Linux install .iso.  There are 3 nodes that act as both control plane and worker, so certain configuration changes are needed to ensure the CP nodes can also act as workstation nodes that are covered within the **cluster-patch.yaml**.

This path ensures we can run pods on the CPs
```
/cluster/allowSchedulingOnControlPlanes: true
```

This allows *metallb* LoadBalancers to run on CPs.  By default, this setting is enabled when a Talos configuration is generated.
```
/machine/nodeLabels/node.kubernetes.io/exclude-from-external-load-balancers:
  $patch: delete
```

## VM Configuration

### Control Plane Nodes
- CPU: 1x Socket, 4x Cores, 2x Threads
- CPU Mode: Host Model 
- Memory: 16GB
- Disk Configuration:
  - (1001) Install disk :: /dev/vda :: 100 GiB VirtIO
  - (1002) Hostpath PVs :: /dev/vdb :: 100 GiB VirtIO
  - (1003) Replicated PVs :: /dev/vdc :: 250 GiB VirtIO
- NIC Configuration
  - (1004) VirtIO :: ens3
  - (1005) VirtIO :: ens4
    
### Worker Nodes
- No dedicated Worker nodes

Instructions for building a fresh Talos cluster can be found here: https://www.talos.dev/v1.9/introduction/getting-started/

## Cluster Configuration
- Talos Nodes Subnet: **10.6.64.0/26**
- Cluster Name: **talos-pa**
- K8s API IP: **10.6.64.20**
- K8s API URL:  **https://talos-pa.domain.local/**  (must resolve to K8s API IP)

## Initialize the Cluster

```
talosctl gen config talos-pa https://talos-pa.domain.local --config-patch cluster-patch.yaml
```
