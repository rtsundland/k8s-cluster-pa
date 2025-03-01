# Talos Cluster (talos-pa)

## Source Documentation
https://www.talos.dev/v1.9/introduction/getting-started/

## Background
This cluster is built using TrueNAS virtual machines using the base metal Talos Linux install .iso.  There are 3 control plane nodes and 3 worker nodes

In certain configurations, changes are needed to ensure the CP nodes can also act as workstation nodes that are covered within the **cluster-patch.yaml**.

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
### CPU and Memory

| Node Type | CPU Sockets | CPU Cores | CPU Threads | Memory | Count |
|-----------|-------------|-----------|-------------|--------|-------|
| Control Plane | 1 | 2 | 2 | 4GB | 3 |
| Worker | 1 | 2 | 8 | 32GB | 3 |

### Disk Configuration
Both Control Plane and Worker Nodes have a base 100GiB filesystem per Talos recommendation.

The workers have additional disks attached which are then passed to OpenEBS (mayastor) for replicated storage.

All disks are mounted to the TrueNAS VM's using VirtIO.

| Node Type | Disk Description | Order | Talos Device Name | Size |
|----------|---------|----------|---------- |--------|
| C/W | Talos Installation | 1001 | /dev/vda | 100 GiB |
| W | Hot Application Pool | 1002 | /dev/vdb | 250GiB | 
| W | Warm Application Pool | 1003 | /dev/vdc | 1 TiB |

Within OpenEBS you will see how *vdb* and *vdc* are used to create replicated and non-replicated persistent volumes.

Hot and Warm just coorespond to NVME Drives vs traditional HD drives (spinsters).  There is a need for both.

Additionally, some charts will use NFS to mount from TrueNAS Scale directly.  Plan to add a *Cold* pool using NFS in the future.

### NIC Configuration

Use *VirtIO* Mode for all NICs

| Order | Talos Device Name |
| ----- | ----- |
| 1004 | ens3 |

Instructions for building a fresh Talos cluster can be found here: https://www.talos.dev/v1.9/introduction/getting-started/

## Cluster Configuration
- Talos Nodes Subnet: **10.6.64.0/26**
- Cluster Name: **talos-pa**
- K8s API IP: **10.6.64.20**
- K8s API URL:  **https://talos-pa.domain.local/**  (must resolve to K8s API IP)

## Generate the Cluster Configuration

```
talosctl gen config talos-pa https://talos-pa.domain.local
```
## Boot VM's

The VM's will boot with DHCP, if static leases are not configured, you'll need to discover what IPs these nodes are using by reviewing the console of each host.  For this configuration, static leases were configured for the hosts:

| Hostname | IP Address |
| --------------- | --------------- |
| talos-pa-c1 | 10.6.64.21 |
| talos-pa-c2 | 10.6.64.22 |
| talos-pa-c3 | 10.6.64.23 |
| talos-pa-w1 | 10.6.64.24 |
| talos-pa-w2 | 10.6.64.25 |
| talos-pa-w3 | 10.6.64.26 |

## Deploy Control Plane Nodes

Initialize each *control plane* node within the cluster, applying the proper configuration changes.  Repeat for each control plane node in the cluster, replacing the hostname and IP address accordingly.

```
talosctl apply-config --insecure -n 10.6.64.21 \
  --config-patch @cluster.patch.yaml \
  --config-patch @controlplane.patch.yaml \
  --config-patch '[{"op": "add", "path": "/machine/network/hostname", "value": "talos-pa-c1"}]' \
  --file controlplane.yaml
```

## Bootstrap the Cluster

After initializing all the control plane nodes, we'll bootstrap the cluster on one node and grab the kubeconfig to access the cluster via *kubectl*

```
talosctl bootstrap --nodes 10.6.64.21 --endpoints 10.6.64.21 --talosconfig=./talosconfig
talosctl kubeconfig --nodes 10.6.64.21 --endpoints 10.6.64.21 --talosconfig=./talosconfig
```

## Update endpoints array in talosconfig
This updates ensures we don't have to add -e <ip> to every talosctl command.
```yaml
context: talos-pa
contexts:
    talos-pa:
        endpoints: [ 10.6.64.21, 10.6.64.22, 10.6.64.23, 10.6.64.24, 10.6.64.25, 10.6.64.26 ]
```

## Verify Node Ready
```
kubectl get nodes
```
Output:
```
NAME         STATUS   ROLES           AGE     VERSION
talos-pa-c1   Ready    control-plane   31d   v1.32.0
talos-pa-c2   Ready    control-plane   31d   v1.32.0
talos-pa-c3   Ready    control-plane   31d   v1.32.0
```

## Deploy Worker Nodes
Worker nodes are deployed in a similar manner, except replacing the *controlplane.patch.yaml* with *worker.patch.yaml* and *controlplane.yaml* with *worker.yaml*.  Deploy as many workers as needed.

```
talosctl apply-config --insecure -n 10.6.64.21 \
  --config-patch @cluster.patch.yaml \
  --config-patch @worker.patch.yaml \
  --config-patch '[{"op": "add", "path": "/machine/network/hostname", "value": "talos-pa-w1"}]' \
  --file worker.yaml
```

## Verify Worker Nodes are Ready
```
kubectl get nodes
```
Output
```
k get nodes
NAME          STATUS   ROLES           AGE   VERSION
talos-pa-c1   Ready    control-plane   31d   v1.32.0
talos-pa-c2   Ready    control-plane   31d   v1.32.0
talos-pa-c3   Ready    control-plane   31d   v1.32.0
talos-pa-w1   Ready    <none>          31d   v1.32.0
talos-pa-w2   Ready    <none>          31d   v1.32.0
talos-pa-w3   Ready    <none>          31d   v1.32.0
```

