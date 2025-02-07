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

## Install the kubectl plugin
The mayastor plugin for kubectl provides additional commands and views into the data kept within OpenEBS.  The plugin can be obtained from:

https://openebs.io/docs/user-guides/replicated-storage-user-guide/replicated-pv-mayastor/advanced-operations/kubectl-plugin


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

## Configure the default snapshot class
This configures OpenEBS to create snapshots of the mayastor PV volumes class.  This is used later within Velero to create snapshots.
```
kubectl apply -f volumesnapshotclass/default.volumesnapshotclass.yaml
```
The `deletionPolicy` on this is set to Retain by default.  This means the snapshots will be retained unless specifically deleted.

# Troubleshooting

## Orphaned Volumes
When a PV is removed, it will sometimes leave orphaned volumes.  Volumes can be found within OpenEBS running the following command:
```
kubectl -n openebs mayastor get volumes
```

Output:
```
 ID                                    REPLICAS  TARGET-NODE  ACCESSIBILITY  STATUS  SIZE     THIN-PROVISIONED  ALLOCATED  SNAPSHOTS  SOURCE
 0b3638a2-5798-4aa0-bb84-b4680408ae88  2         <none>       <none>         Online  18.6GiB  true              8MiB       0          <none>
 7eb302c6-7b36-4405-9c91-53f7910d434a  2         talos-pa-w2  nvmf           Online  20GiB    true              14.8GiB    1          <none>
 abd94922-f787-4023-a0c7-15198922658f  2         <none>       <none>         Online  20GiB    true              92MiB      0          <none>
```

The ID reported in this output corresponds directly to an existing PV, e.g. *7eb302c6-7b36-4405-9c91-53f7910d434a* will be named pvc-*7eb302c6-7b36-4405-9c91-53f7910d434a*
```
kubectl get -A persistentvolume/pvc-7eb302c6-7b36-4405-9c91-53f7910d434a
``
will have an output like:
```
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                      STORAGECLASS        VOLUMEATTRIBUTESCLASS   REASON   AGE
pvc-7eb302c6-7b36-4405-9c91-53f7910d434a   20Gi       RWO            Retain           Bound    somens/somepod   													some-storage	<unset>                          23h
```

In this case, *0b3638a2-5798-4aa0-bb84-b4680408ae88* and *abd94922-f787-4023-a0c7-15198922658f* are both orphaned since there is no existing PV. 

Deleting these orphaned volumes requires setting up a port forwarding to the OpenEBS API and deleting using curl where xxxxxxxxx is the ID of the volume:
```
k -n openebs port-forward svc/openebs-api-rest 8081:8081
curl -X DELETE 'http://localhost:8081/v0/volumes/xxxxxxxxx'
```

## Orphaned Snapshots
Snapshots can be orphaned when you do bad things.  You can identify snapshots running:
```
kubectl -n openebs mayastor get volume-snapshots
```
Output looks like:
```
 ID                                    TIMESTAMP             SOURCE-SIZE  ALLOCATED-SIZE  TOTAL-ALLOCATED-SIZE  SOURCE-VOL                            RESTORES  SNAPSHOT_REPLICAS
 1151a80d-7913-4cb2-9d44-83d4b6601294  2025-01-31T11:22:05Z  20GiB        15.6GiB         15.6GiB               5f1ac57b-fb0d-4170-acfe-fd0b4d593b58  0         2
 2d672751-aa34-4290-a140-4fa9af65bffc  2025-02-04T17:05:16Z  20GiB        3.4GiB          19GiB                 5f1ac57b-fb0d-4170-acfe-fd0b4d593b58  0         2
```

Should be able to match up the SOURCE-VOL column to a volume running:
```
kubectl -n openebs mayastor get volumes
```

If no matching volume exists, it may be orphaned.  Deleting the orphaned snapshots must be done through the API:
```
k -n openebs port-forward svc/openebs-api-rest 8081:8081
curl -X DELETE 'http://localhost:8081/v0/volumes/snapshots/xxxxxxxxx'
```
... where xxxxxxxx is the ID of the snapshot
