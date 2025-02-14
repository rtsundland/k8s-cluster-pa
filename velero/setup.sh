#!/usr/bin/env bash

echo %
echo % Three parameters will come from the bucket configuration:  Name, Region, and Endpoint
echo %
read -p "Bucket Name: " BUCKET
if [ -z "${BUCKET}" ] || [ "${BUCKET}" = "" ]
then	echo "Invalid bucket value, exiting" 1>&2
			exit 2
fi

read -p "Region: " REGION
if [ -z "${REGION}" ] || [ "${REGION}" = "" ]
then	echo "Invalid region value, exiting" 1>&2
			exit 2
fi

read -p "Bucket Endpoint: " ENDPOINT
if [ -z "${ENDPOINT}" ] || [ "${ENDPOINT}" = "" ]
then	echo "Invalid endpointvalue, exiting" 1>&2
			exit 2
fi

# corect the endpoint
ENDPOINT="https://$(echo ${ENDPOINT} | sed 's#^[[:alnum:]]\+://##g')"

echo
echo %
echo % Create an Application Key with read/write access to the bucket.  The Key ID and Key Secret will be needed:
echo %
read -p "Application Key ID: " KEYID
read -s -p "Secret: " SECRET
echo
if [ -z "${KEYID}" ] || [ "${KEYID}" = "" ] || [ -z "${SECRET}" ] || [ "${SECRET}" = "" ]
then	echo "Invalid Application key or secret, exiting" 1>&2
			exit 2
fi
echo

# build the temp credfile
CREDFILE=$(mktemp)
cat <<EOF > "${CREDFILE}"
[default]
aws_access_key_id=${KEYID}
aws_secret_access_key=${SECRET}
EOF


velero install \
	-n velero \
	--use-node-agent \
	--features=EnableCSI \
	--provider aws \
	--plugins velero/velero-plugin-for-aws:v1.11.0 \
	--secret-file "${CREDFILE}" \
	--bucket "${BUCKET}" \
	--backup-location-config region=${REGION},s3Url="${ENDPOINT}",s3ForcePathStyle=true,checksumAlgorithm="" \
	--snapshot-location-config region=${REGION}

rm -f "${CREDFILE}"

