# Talos Cluster (talos-pa)

## Source Documentation
https://www.talos.dev/v1.9/introduction/getting-started/

## Background
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

**CPU And Memory**

- CPU: 1x Socket, 4x Cores, 2x Threads
- CPU Mode: Host Model 
- Memory: 16GB

**Disk Configuration**

Use *VirtIO* Mode for all Disks

| Disk Description | Order | Talos Device Name | Size |
|----------|---------|----------|---------- |
| Install | 1001 | /dev/vda | 100 GiB |
| Local PVs | 1002 | /dev/vdb | 100 GiB |
| Replicated PVs | 1003 | /dev/vdc | 250 GiB |

**NIC Configuration**

Use *VirtIO* Mode for all NICs

| Order | Talos Device Name |
| ----- | ----- |
| 1004 | ens3 |
| 1005 | ens4 |

### Worker Nodes
- No dedicated Worker nodes

Instructions for building a fresh Talos cluster can be found here: https://www.talos.dev/v1.9/introduction/getting-started/

## Cluster Configuration
- Talos Nodes Subnet: **10.6.64.0/26**
- Cluster Name: **talos-pa**
- K8s API IP: **10.6.64.20**
- K8s API URL:  **https://talos-pa.domain.local/**  (must resolve to K8s API IP)

## Generate the Cluster Configuration

```
talosctl gen config talos-pa https://talos-pa.domain.local --config-patch cluster-patch.yaml
```
## Boot VM's

The VM's will boot with DHCP, if static leases are not configured, you'll need to discover what IPs these nodes are using by reviewing the console of each host.  For this configuration, static leases were configured for the hosts:

| Hostname | IP Address |
| --------------- | --------------- |
| talos-pa-1 | 10.6.64.21 |
| talos-pa-2 | 10.6.64.22 |
| talos-pa-3 | 10.6.64.23 |

## Deploy First Node

For each node within the cluster, apply the generated *controlplane.yaml* to each node (repeat for each node/hostname/ip)

```
talosctl apply-config --insecure -n 10.6.64.21 \
  --config-patch '[{"op": "add", "path": "/machine/network/hostname", "value": "talos-pa-1"}]' \
  --file controlplane.yaml
```

## Bootstrap the Cluster

After bootstrap, we'll grab the kubeconfig to access the cluster via *kubectl*

```
talosctl bootstrap --nodes 10.6.64.21 --endpoint 10.6.64.21 --talosconfig=./talosconfig
talosctl kubeconfig --nodes 10.6.64.21 --endpoint 10.6.64.21 --talosconfig=./talosconfig
```

## Update endpoints array in talosconfig
This updates ensures we don't have to add -e <ip> to every talosctl command.
```
context: talos-pa
contexts:
    talos-pa:
        endpoints: [ 10.6.64.21, 10.6.64.22, 10.6.64.23 ]
```

## Deploy Remaining Nodes

**talos-pa-2**
```
talosctl apply-config --insecure -n 10.6.64.22 \
  --config-patch '[{"op": "add", "path": "/machine/network/hostname", "value": "talos-pa-2"}]' \
  --file controlplane.yaml
```

**talos-pa-3**
```
talosctl apply-config --insecure -n 10.6.64.23 \
  --config-patch '[{"op": "add", "path": "/machine/network/hostname", "value": "talos-pa-3"}]' \
  --file controlplane.yaml
```

## Verify Node Ready
```
kubectl get nodes
```
Output:
```
NAME         STATUS   ROLES           AGE     VERSION
talos-pa-1   Ready    control-plane   2d21h   v1.32.0
talos-pa-2   Ready    control-plane   2d21h   v1.32.0
talos-pa-3   Ready    control-plane   2d21h   v1.32.0
```

