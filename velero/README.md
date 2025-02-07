# Velero

## Source Documentation
https://velero.io/

https://github.com/vmware-tanzu/velero/

https://blachniet.com/posts/backup-your-kubernetes-cluster-with-velero-and-backblaze/

## Configure Backblaze B2

1. Log into Backblaze
2. Create a new bucket (if required)
3. Configure an access token to that bucket (readwrite)
4. Use the access token to create a secret file and save it as `backblaze.secret`:
```
[default]
aws_access_key_id=XXXXXXXXXXXXXXXXX
aws_secret_access_key=XXXXXXXXXXXXXXXXXXXXXXXXXXXX
```
5. Define some variables we'll use in our installation:
```
#
# bucket you created
BUCKET='MYBUCKET'

#
# region the bucket was created in (look at bucket properties)
REGION='REGIONNAME'

#
# the endpoint hostname for the bucket
ENDPOINT='https://ENDPOINT.HOSTNAME'

#
# the secret file created in the last step
CREDFILE='backblaze.secret'
```

## Install Velero
Velero has a command line utility for managing the velero services and doing installation.  

1. Download the latest version from the Velero github site:
			https://github.com/vmware-tanzu/velero/releases/

2. Extract the file to your local directory
3. Move the extracted `velero` binary to /usr/local/bin or other location in your PATH

4. Run the velero installer:
```
velero install \
	-n velero \
	--features=EnableCSI \
	--provider aws \
	--plugins velero/velero-plugin-for-aws:v1.11.0 \		# use the latest plugin version
	--secret-file "${CREDFILE}" \
	--bucket "${BUCKET}" \
	--backup-location-config region=${REGION},s3Url="${ENDPOINT}",s3ForcePathStyle=true,checksumAlgorithm="" \
	--snapshot-location-config region=${REGION}
```

5. Profit

