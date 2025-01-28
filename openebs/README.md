# OpenEBS Installation and Configuration

## Source Documentation
https://www.talos.dev/v1.9/kubernetes-guides/configuration/storage/

https://openebs.io/docs/quickstart-guide/installation#installation-via-helm

## Apply Talos Patches
If not already applied, there are two Talos patches that need to be applied to both the CP and work nodes.  This should've already been done during the cluster build, but best check to ensure they are applied here:

### Control Plane
> [!Note]
> Apply to each control plane node

`talosctl patch mc -p @talos/controlplane.patch.yaml`

### Worker
> [!Note]
> Apply to each worker node

`talosctl patch mc -p @talos/worker.patch.yaml`

## Install Helm Chart
```
helm repo add openebs https://openebs.github.io/charts
helm repo update
helm install -n openebs --create-namespace openebs openebs/openebs -f values.yaml
```

## Disk Pools

### Current Diskpool Configurations
There are currently two diskpools that are labeled by the zpool they are configured on within TrueNAS
- kenobi (nvme storage)
- vader (spinny disk storage)


### Configure Disk Pools for Each Node
Since each node could be different and Diskpool is node specific configuration, Diskpool configurations have been broken out for each worker node under [diskpools](diskpools/). 

Import all diskpool configurations:
```
kubectl -n openebs create -f diskpools/
```

Or import one at a time:
> [!Note]
> Run this for every node/file.

```
kubectl -n openebs create -f diskpools/talos_pa_w1.yaml
```

## Configure Storage Class
The storage class makes use of the diskpool previous configured and sets it as the default.  To import all:
```
kubectl -n openebs create -f storageclass/
```
Or to just import one:
```
kubectl -n openebs create -f storageclass/kenobi-single.storageclass.yaml
```

