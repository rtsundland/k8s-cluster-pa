# Installing prometheus-operator

## Source Documentation
https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

## Add Repo and Install
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install -n prometheus --create-namespace prometheus prometheus-community/kube-prometheus-stack
```
