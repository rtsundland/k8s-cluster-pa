# Installing cert-manager and clusterissuer

## Source Documentation
https://truecharts.org/charts/premium/clusterissuer/how-to/

https://truecharts.org/charts/system/kubernetes-reflector/

## Background
This is an installation of 3 different charts to enable automatic certificate generation across the cluster:
- kubernetes-reflector
- cert-manager
- clusterissuer

All three charts are installed from the TrueCharts project

## Create Namespace
```
kubectl create ns tc-cert-manager
```

## Install kubernetes-reflector
```
helm install -n default kubernetes-reflector oci://tccr.io/truecharts/kubernetes-reflector
```
## Install cert-manager
```
helm install -n tc-cert-manager cert-manager oci://tccr.io/truecharts/cert-manager
```

If we want to overwrite the dns01 nameservers, we can use **cert-manager.values.yaml**
```
helm install -n tc-cert-manager cert-manager oci://tccr.io/truecharts/cert-manager -f cert-manager.values.yaml
```

## Setup ACME w/ LetsEncrypt
The file *clusterissuer.values.yaml-template* contains the outline of how to creatre certificatre issuers for Letsencrypt, prod and staging, using Cloudflare as a domain authenticator.  Specific credentials need to be obtained from Cloudflare and updated before installing *clusterissuer*.

```
cp clusterissuer.values.yaml-template clusterissuer.values.yaml
```

### Setup Cloudflare API key
Modify *clusterissuer.values.yaml* to include the necessary credentials for Cloudflare verification
```yaml
clusterIssuer:
  ACME:
    - name: 'letsencrypt-prod'
      server: 'https://acme-v02.api.letsencrypt.org/directory'
      email: "<email-here>"
      type: "cloudflare"
      cfapitoken: "<api-token-here>"

    - name: 'letsencrypt-staging'
      server: 'https://acme-staging-v02.api.letsencrypt.org/directory'
      email: "<email-here>"
      type: "cloudflare"
      cfapitoken: "<api-token-here>"
```

### Setup Cluster Wildcard Certificate
Modify *clusterissuer.values.yaml* with the cluster-wide certificate you want to generate for your cluster, or comment it out, I don't care.

When setup, upon installation of *clusterissuer* it will attempt to register this certificate with ACME and then *kubernetes-reflector* will copy it everywhere.

```yaml
clusterCertificates:
  replicationNamespaces: 'tc-.*'
  certificates:
    - name: domain-local
      enabled: true
      certificateIssuer: letsencrypt-prod
      hosts:
        - 'domain.local'
        - '*.domain.local'
```

### Install clusterissuer
```
helm install -n tc-cert-manager clusterissuer oci://tccr.io/truecharts/clusterissuer -f clusterissuer.values.yaml
```
