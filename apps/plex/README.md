# Plex

## Source Documentation
https://github.com/plexinc/pms-docker/tree/master/charts/plex-media-server

## Installation
```
helm repo add plex https://raw.githubusercontent.com/plexinc/pms-docker/gh-pages
helm repo update
helm upgrade --install plex -n plex plex/plex-media-server -f values.yaml
```

## Configure IngressRoute
```
kubectl apply -f plex.ingressroute.yaml
```

## Notes
The initContainer script is configured to look file a file called `/backup/.restore`.  If this file exists, it will read the name of the backup file from `/backup/.restore`, prepend `/backup` and extract the gzip'd tarball into the /config directory.  The archive should be created starting from the `Library/` path down.  The old `Library/` subpath will be renamed with an appended date, just in case.

> [!WARNING]
> This will replace any existing configuration, so should only be used on startup of a new instance, migrations, or extreme emergencies.
