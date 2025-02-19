#!/usr/bin/env bash

function generateSecretFile() {
  cat <<EOF
#
# specify the default default admin username
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="changeme"

#
# this defines the database credentials for the application accessing CNPG
DB_USERNAME="nextcloud"
DB_PASSWORD="<enter strong password here>"

#
# this will define the credential used for performin the CNPG backup and restore of the database
S3_URL="<url>"
S3_PATH="<path>"
S3_BUCKET="<bucket>"
S3_ACCESSKEY="<access-key-id>"
S3_SECRETKEY="<secret-key>"

#
# hosts to configure for this instance.  the primary should be first since the chart
# will use it as the overwrite url
APP_HOSTNAMES=(
	"nextcloud.sundland.net"
	"nextcloud.home.sundland.net"
	"nextcloud.apps.home.sundland.net"
)
EOF

}

function showhelp() {
  cat <<EOF 1>&2

This setup file will generate a blank secret file and then use it to update the default values.yaml file

To generate a new, blank secret file from a template, do:

  $0 -g > somefile.secret

After editing you can then run the following command to see the modifiations made to the values.yaml file

  $0 -s somefile.secret

When you're ready to install, add the -i switch

  $0 -s somefile.secret -i

If you don't want to use S3 backups, then keep S3_URL blank.

EOF

}

RUNCMD="cat"  # default will just output the created yaml
INSTALLCMD="helm upgrade --install --create-namespace -n tc-nextcloud nextcloud oci://tccr.io/truecharts/nextcloud -f -"

while getopts ":gis:" opt
do	case "${opt}" in
			g)	generateSecretFile && exit 2;;
			s)	secretFile=${OPTARG};;
      i)  RUNCMD="${INSTALLCMD}";;
			h)  showhelp; exit;;
		esac
done
shift $((OPTIND-1))

if [ -z "${secretFile}" ]
then  showhelp; exit 2
fi

#
# will read the provided secret file and update values.yaml with 
source $secretFile

#
# handle hostnames
str="."
for i in ${!APP_HOSTNAMES[@]}
do		str="$str | .ingress.main.hosts += { \"host\": \"${APP_HOSTNAMES[$i]}\" }"
			str="$str | .ingress.main.tls[].hosts += [ \"${APP_HOSTNAMES[$i]}\" ]"
done

#
# configures default admin username and password
str=$(printf '%s | .nextcloud.credentials = { "initialAdminUser": "%s", "initialAdminPAssword": "%s" }' "$str" "$ADMIN_USERNAME" "$ADMIN_PASSWORD")

#
# configures db access
str=$(printf '%s | .cnpg.main += { "owner": "%s", "password": "%s" }' "$str" "$DB_USERNAME" "$DB_PASSWORD")

#
# setup the s3 backups
# first, generate a random credential name, create the credentials, and then update cnpg with the credential info
if [ ! -z "${S3_URL}" ]
then
  name=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 13; echo)
  str=$( printf '%s | .credentials += { "%s": { "type": "s3", "url": "%s", "path": "%s", "bucket": "%s", "accessKey": "%s", "secretKey": "%s", "encrKey": "%s" } }' "${str}" "${name}" "${S3_URL}" "${S3_PATH}" "${S3_BUCKET}" "${S3_ACCESSKEY}" "${S3_SECRETKEY}" "${S3_ENCRYPTKEY}" )
  str=$( printf '%s | .cnpg.main.backups.credentials = "%s"' "${str}" "${name}" )
  str=$( printf '%s | .cnpg.main.recovery.credentials = "%s"' "${str}" "${name}" )
else
  # delete the backups and recovery keys from the yaml
  str=$( printf '%s | del(.cnpg.main.backups) | del(.cnpg.main.recovery)' "${str}" )
fi

cat values.yaml | \
  yq "$str" | \
  ${RUNCMD}

