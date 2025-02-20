# Nextcloud

## Supporting Documentation
https://truecharts.org/charts/premium/nextcloud/

## Installation
This chart has a specific setup.sh for our environment.  Running setup.sh will allow you to generate a secret file with credentials for the installation (or re-installation)
or Nextcloud, and then run the helm installation.

```
chmod u+x ./setup.sh
./setup.sh -g > somefile.secret
```

Edit `somefile.secret` with the parameters needed.  Then run this to install the chart.  You can optionally remove the `-i` to see the generated values.yaml based on
the values in somefile.secret

```
./setup.sh -s somefile.secret -i
```

## Backups
CNPG configuration handles the backup of the database, we'll use **velero** to perform the backups of the non-data PVs and configurations.

Nextcloud backups should take place every night, since data can change frequently.  This will run the backups and copy the PVs to the S3 bucket configured every
morning at 2AM. (Cron Time in UTC, +0500 from EST)

```
velero create schedule nextcloud --schedule="01 07 * * *" --include-namespaces tc-nextcloud --snapshot-volumes --snapshot-move-data
```

