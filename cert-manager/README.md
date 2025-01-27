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

## Install kubernetes-reflector
```
helm install -n default kubernetes-reflector ci://tccr.io/truecharts/kubernetes-reflector
```
## Install cert-manager
```
helm install -n tc-cert-manager --create-namespace cert-manager oci://tccr.io/truecharts/cert-manager
```

If we want to overwrite the dns01 nameservers, we can use **cert-manager.values.yaml**
```
helm install -n tc-cert-manager --create-namespace cert-manager oci://tccr.io/truecharts/cert-manager -f cert-manager.values.yaml
```

## Setup ACME w/ LetsEncrypt
The clusterissuer.values.yaml file contains some configuration information that must be modified before installing.

### Setup Cloudflare API key

Sets up LetsEncrypt production and staging certificate issuers using Cloudflare verification
```
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

Generates a cluster-wide wildcard certificate using production LetsEncrypt that can be used for any services under the domain specified.  Note the replicatedNamespaces parameter will only replicate to namespaces starting with 'tc-' (uses regular expression matching).
```
clusterCertificates:
  replicationNamespaces: 'tc-.*'
  certificates:
    - name: home-sundland-net
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
