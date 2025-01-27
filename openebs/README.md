# OpenEBS Installation and Configuration

## Source Documentation
https://www.talos.dev/v1.9/kubernetes-guides/configuration/storage/
https://openebs.io/docs/quickstart-guide/installation#installation-via-helm

## Patch Talos
Patch the Talos machineconfig to provide proper paraemters for OpenEBS to run, mount disks in the correct locations, and assign proper nodes labels.  This patch needs to be run on each node, example for talos-pa-1.  Since the Controlplane and Worker Nodes are the same in this cluster, we're applying both patches to each device:
```
talosctl patch mc -n 10.6.64.$21 \
  --patch-file controlplane.patch.yaml --patch-file worker.patch.yaml
```

## Install Helm Chart
```
helm repo add openebs https://openebs.github.io/charts
helm repo update
helm install -n openebs --create-namespace openebs openebs/openebs -f values.yaml
```

## Configure Disk Pool
The diskpool is configured from /dev/vdc that was configured within the cluster and acknowledge in *worker.patch.yaml*
```
kubectl -n openebs create -f app-pool-diskpool.yaml
```

## Configure Storage Class
The storage class makes use of the diskpool previous configured and sets it as the default.
```
kubectl -n openebs create -f app-default.storageclass.yaml
```
