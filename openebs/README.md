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
