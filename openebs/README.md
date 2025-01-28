# OpenEBS Installation and Configuration

## Source Documentation
https://www.talos.dev/v1.9/kubernetes-guides/configuration/storage/
https://openebs.io/docs/quickstart-guide/installation#installation-via-helm

## Patch Talos
Ensure the talos machine configuration has the following patch applied.  This should be done within the cluster build.  This yaml is saved as *worker.patch.yaml* here.
```
machine:
  sysctls:
    vm.nr_hugepages: "1024"
  nodeLabels:
    openebs.io/engine: "mayastor"
```

## Install Helm Chart
```
helm repo add openebs https://openebs.github.io/charts
helm repo update
helm install -n openebs --create-namespace openebs openebs/openebs -f values.yaml
```

## Configure Disk Pools for Each Node
Since each node could be different and Diskpool is node specific configuration, Diskpool configurations have been broken out for each worker node under [by-node](by-node/). 

Apply the diskpool configurations for each node:
```
kubectl -n openebs create -f by-node/talos_pa_w1.yaml
kubectl -n openebs create -f by-node/talos_pa_w2.yaml
...
```
### Current Diskpool Configurations
There are currently two diskpools that are labeled by the zpool they are configured on within TrueNAS
- kenobi (nvme storage)
- vader (spinny disk storage)

## Configure Storage Class
The storage class makes use of the diskpool previous configured and sets it as the default.
```
kubectl -n openebs create -f app-default.storageclass.yaml
```
