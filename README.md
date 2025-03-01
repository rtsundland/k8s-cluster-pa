# Talos Cluster Part A

## Overview
This is built as a replacement for running apps directly on TrueNAS.  AI'm a huge fan of TrueNAS, and FreeNAS before it, using it since almost its inception... 
but as TrueNAS transitioned away from Kubernetes to Docker-only, I found myself conflicted about ongoing support by iX Systems and feel they may try another
major overhaul on their app system that would be frustrating.  The TrueNAS Core transition to Scale then From Scale Kuberentes to Scale Docker is too much for a 
guy who is lazy.

At the same time, I decided it would be good to really dive into Kubernetes a bit more.

This project is built using VM's provisioned on TrueNAS scale using [Talos Linux](https://www.talos.dev) with native Kubernetes and all the fun that goes with it.

Huge learning curve, so decided to document everything I did so I can rebuild the entire cluster faster than I built it initially.

## Philosophy
Every app is exposed on a single load balanced IP with a wildcard certificate issued by Let's Encrypt.  Apps are under the directory <appname>.apps.mycluster.local or
similar.  All are exposed through Traefik, and then apps that require their own load balancer config (like Plex) has another IP assigned to it.

- All Apps are proxied through Traefik
- All Traefik through Traefik is TLS'd with Let's Encrypt
- All Apps are deployed under a common IP/domain
- Traefik IngressRoute is used in most situations to be more flexible with the ingress
- Access to apps is through Cloudflare Zero Trust (TBD)


## Installation
Below is an installation of the *core* deployments that make up the cluster.  This is where I started, and then once this was done I went to installing the apps I needed.
Much of this information comes from tutorials on Talos' website, OpenEBS, Metallb, and TrueCharts documentation.

I did not follow the full TrueCharts model, which will probably bite me in the ass later, but decided on a hybrid model as I become more familiar with Kubernetes.

Each *core* app has its own README.md on performing the installation.

1.  [Talos Cluster](cluster/)
2.  [OpenEBS](openebs/)
3.  [Metallb](metallb/)
4.  [Prometheus Operator](prometheus-operator/)
6.  [Cert-Manager/ClusterIssuer/Kubernetes Reflector](cert-manager/)
7.  [Traefik](traefik/)
8.  [Cloudnative Postgres (CNPG)](cnpg/)
9.  [Velero](velero/)
10. [Cloudflare](cloudflared/)

## App Installation
App deployments are covered with their own README's as well.

Go here: [Apps](apps/)

## Migration
Under the apps folder is a migration tool.  It allows me to mount volumes inside an ubuntu pod and perform random actions.  The simplest thing to do is to copy files,
but it can be used to modify config files, paths, etc. before performing app deployments using helm.  I found it useful in cases of like Nextcloud where the configurations
were available via NFS, but I wanted to move them to PVCs or when I migrated my Plex server from an NFS share.

## TODO
Cloudflare Zero Trust for all app access

For *core* deployments, in no particular order...
- Complete backup configuration documentation, particularly around scheduling
- Research Calico for microsegmentation
- Spend more time understanding Traefik
- Configure prometheus properly
- Dedicated hardware instead of VMs
- Minio Operator and Tenants

For *app* deployments, also in no particular order...
- Setup homepage as a jumping off point for everything
- Eliminate the dependencies on TrueCharts as much as possible
- More flexible model for secret management
- Add Blocky and/or unbound?
- Research more apps
