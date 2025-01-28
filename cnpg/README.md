# Cloudnative Postgres or CNPG or Cloudnative-PG

## Source Documentation
https://github.com/cloudnative-pg/charts

## Install
```
helm repo add cnpg https://cloudnative-pg.github.io/charts
helm upgrade --install cnpg \
  --namespace cnpg-system \
  --create-namespace \
  cnpg/cloudnative-pg
```

## Create Test Cluster
```
cat <<EOF | kubectl apply -f -
  # Example of PostgreSQL cluster
  apiVersion: postgresql.cnpg.io/v1
  kind: Cluster
  metadata:
    name: cluster-example
  spec:
    instances: 3
    storage:
      size: 1Gi
      storageClass: kenobi-single # this is optional but for clusters probably preferred

EOF
```

## Check cluster status
When still initializing, the **STATUS** field will respond *Setting up primary* and when complete will change to *Cluster in healthy status*

```
kubectl get cluster -t default
```

Output

```
NAME              AGE     INSTANCES   READY   STATUS                     PRIMARY
cluster-example   2m10s   3           3       Cluster in healthy state   cluster-example-1
```

Since the cluster we created has 3 instances, we should also see 3 PV claims setup each with 1Gi allocated:

```
k get pv |grep cluster-example
```

Output
```
pvc-470dc80a-4229-433e-b500-d67990bae0cf   1Gi        RWO            Delete           Bound    default/cluster-example-3        apps-default            <unset>                          2m23s
pvc-68304980-38df-4f21-83ce-ac255cf7eee5   1Gi        RWO            Delete           Bound    default/cluster-example-2        apps-default            <unset>                          3m2s
pvc-e806b3b3-e2fe-4e59-ac46-2aa7533db643   1Gi        RWO            Delete           Bound    default/cluster-example-1        apps-default            <unset>                          3m46s
```

And similarly, we'll see three claims

## Delete Test Cluster

````
kubectl delete cluster cluster-example
```

It may take a few seconds, but the PV claims should also disappear from OpenEBS.
