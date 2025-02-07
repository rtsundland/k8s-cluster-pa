# Velero

## Source Documentation
https://velero.io/

https://github.com/vmware-tanzu/velero/

https://blachniet.com/posts/backup-your-kubernetes-cluster-with-velero-and-backblaze/

## Download and Install Velero
Velero has a command line utility for managing the velero services and doing installation.  

1. Download the latest version from the Velero github site:
			https://github.com/vmware-tanzu/velero/releases/

2. Extract the file to your local directory
3. Move the extracted `velero` binary to /usr/local/bin or other location in your PATH

## Configure Backblaze B2

1. Log into Backblaze
2. Create a new bucket (if required)
3. Configure an access token to that bucket (readwrite)

## Setup Velero
I've written a `setup.sh` script to install *velero* with the proper parameters.
```
bash setup.sh
```
It will prompt you for what you need, create a temporary secret file, install velero, and delete the secret file.

You can validate a proper installation by running:
```
kubectl get all -n velero
```
which should produce an output like:
```
NAME                          READY   STATUS    RESTARTS   AGE
pod/velero-7d5cc48999-7wrlz   1/1     Running   0          5h15m

NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/velero   1/1     1            1           24h

NAME                                DESIRED   CURRENT   READY   AGE
replicaset.apps/velero-7d5cc48999   1         1         1       24h
```
