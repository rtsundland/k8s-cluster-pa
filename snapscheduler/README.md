# snapshotscheduler

## Installation
```
helm repo add backube https://backube.github.io/helm-charts/
helm upgrade --install --create-namespace -n backube-snapscheduler snapscheduler backube/snapscheduler
```

## Schedule Snapshots
There are pre-defined schedules for hourly, daily, and weekly snapshot schedules that run at midnight.

Modify as needed.

Snapshot schedules are configured within each namespace and PVCs need to be accordingly labeled to match the defined schedule.

As an example, the pre-defined *hourly* schedule creates a *snapshotschedule* called hourly in the applicable namespace.  Any PVCs in that namespace that you
want to apply an *hourly* snapshot schedule must be labeled with the label `snapshotschedule=hourly`.

### Example for performing hourly snapshots
Install the *hourly* snapshotschedule into your namespace:

```
kubectl -n yournamespace apply -f hourly.snapshotschedule.yaml
```

Then label the PVC(s) in your namespace to that correspond to this schedule:

#### Editing the PVC
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  ...
  labels:
    snapshotschedule: hourly
```

#### Using Patch
Or you can do it by patch (will replace any existing matching label)::
```
kubectl -n [yournamespace] patch pvc [name-of-pvc] -p '{"metadata": { "labels": { "snapshotschedule": "hourly" } } }'
```

