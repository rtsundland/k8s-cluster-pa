# metallb 

metallb is configured with two address pools and a L2 advertisement.  The two address pools allows for an 'admin' pool where cluster-specific services are running, such as prometheus, and an 'app' pool used for general application services.

## Source Documentation
https://metallb.universe.tf/


## Install Helm Repo and Chart
```
helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb -n metallb --create-namespace
```

## Create metallb Namespace with proper permissions
```
kubectl create namespace metallb
kubectl label namespace metallb  \
  pod-security.kubernetes.io/enforce=privileged \
  pod-security.kubernetes.io/audit=privileged \
  pod-security.kubernetes.io/warn=privileged
```

## Add IP Address Pools
```
kubectl -n metallb create -f app-pool.ipaddresspool.yaml -f admin-pool.ipaddresspool.yaml
```

## Add L2 Advertisement
```
kubectl -n metallb create -f l2advertisements.yaml
```
## Configuring Services to Use Address Pools

### Admin Pool
By default, when a service is configured for LoadBalancer, it will be added to the admin-pool and auto-provisioned an IP address by simply specifying:
```yaml
apiVersion: v1
kind: Service
...
spec:
  type: LoadBalancer
```

You can specify an IP address in this pool by providing the proper labels.  Assuming the IP isn't already consumed, of course.
```yaml
apiVersion: v1
kind: Service
...
metadata:
  annotations:
    metallb.io/loadBalancerIPs: <ip-address>
```

### App Pool
When wanting to use a different pool, like *app-pool* you will need to declare it in your annotations such as below.  Since *app-pool* does not automatically allocate an IP address, you will need to supply one too.
```yaml
apiVersion: v1
kind: Service
...
metadata:
  annotations:
    metallb.io/address-pool: app-pool
    metallb.io/loadBalancerIPs: <ip-address>
```

