# Sonarr

## Installation
This is a full TC install, no separate configurations
```
helm upgrade --install -n overseerr --create-namespace overseerr oci://tccr.io/truecharts/overseerr -f values.yaml
```

## Migrate
1. Scale the overseerr deployment to 0 replicas
```
kubectl -n overseerr scale deployment.apps/overseerr --replicas=0
```

2. Use the `migration-utility.sh` to mount the source NFS of the configuration and the `overseerr-config` PVC:
```
../migration-utility.sh -n overseerr -d overseerr-config -s 10.0.1.10:/mnt/vader/backups/restore
```


