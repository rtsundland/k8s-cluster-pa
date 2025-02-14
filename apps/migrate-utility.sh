#!/usr/bin/env bash

podName="migration-pod"
baseImage="ubuntu:latest"
defaultCommand="sh"

showhelp() {
	cat <<EOF
This will run an Ubuntu image in <namespace> mounting the NFS or PV volumes to assist in migrating 
data between different locations and immediately attach you to it with the default command of 
'${defaultCommand}'.  You can specify your own command within the pod, see Usage below.

This is not feature rich and doesn't do everything you may want it to do.  It was built specific
to my needs at the time.

NOTE:  This pod is ephemeral -- any changes you make in the pod will be deleted once you exist 
the pod, except for the things you've done in the mounted volumes.  So in cases where you want
a text editor, it will GO AWAY once you exit the pod.  The next time you run this utility, it
pulls from the source ubuntu image again.  If you want to change this, FEEL FREE but don't bug
me about it.  kthx

Usage:
$0 -n <namespace> [-v <path>] [-v <second-path>] [-v <third-path>] [--] [<command>]

Flags:
	-n <namespace>  	The namespace to run the pod/image
	-v <volume-spec>	Volume to mount, see Volume Spec section.  Can be specified UNLIMITED* times.

You can provide a command at the end to run a specific command in the pod if ${defaultCommand}
is not good enough for you.  You may want to pass '--' to the command line to ensure any flags
passoed to your new, fancy command are not processed by this script.

Volume Spec

There are two supported volume types: NFS and PVC.  And they are defined like this:

	1) NFS => <id>:nfs:<nfs-ipaddress>:<nfs-path>
	2) PVC => <id>:pvc:<pvc-name>

Full Example:  This will run in namespace 'foobar' and mount an NFS volume under '/mnt/volA' and 
a PVC at '/mnt/dest' and run 'bash'

$ $0 -n foobar -v volA:nfs:10.10.10.4:/mnt/blah/somewhere/foobar -v dest:pvc:pvc-foobar-config -- bash

EOF
}

function parseFields() {
	input=$1; shift
	name=$(echo $input | cut -f1 -d:)
	type=$(echo $input | cut -f2 -d:)
	jqfilter=$( printf '%s | .spec.containers[0].volumeMounts += [ { "mountPath": "/mnt/%s", "name": "%s" } ]' "${jqfilter}" "${name}" "${name}" )

	case "${type}" in
		'nfs')	
				server=$(echo $input | cut -f3 -d:)
				path=$(echo $input | cut -f4 -d:)
				jqfilter=$( printf '%s | .spec.volumes += [ { "name": "%s", "nfs": { "server": "%s", "path": "%s" } } ]' "${jqfilter}" "${name}" "${server}" "${path}" )
				;;
		'pvc')
				claim=$(echo $input | cut -f3 -d:)
				jqfilter=$( printf '%s | .spec.volumes += [ { "name": "%s", "persistentVolumeClaim": { "claimName": "%s" } } ]' "${jqfilter}" "${name}" "${claim}" )
				;;
	esac
}


IFS= read -r -d '' jqfilter <<EOF
{
	"apiVersion": "v1",
	"kind": "Pod",
	"spec": {
		"containers": [
			{
				"name": "${podName}",
				"image": "${baseImage}",
				"stdin": true,
				"stdinOnce": true,
				"tty": true,
				"restartPolicy": "Never"
			}
		]
	}
}
EOF

while getopts ":n:v:h" opt
do	case "${opt}" in
			n)	namespace=${OPTARG};;
			v)	parseFields ${OPTARG};;
			h)  showhelp; exit;;
		esac
done
shift $((OPTIND-1))


cmd=$*
if [ -z "${cmd}" ]
then	jqfilter=$( printf '%s | .spec.containers[0].args = [ "%s" ]' "${jqfilter}" "${defaultCommand}" )
else	jqfilter=$( printf '%s | .spec.containers[0].args = [ "sh", "-c", "%s" ]'  "${jqfilter}" "${cmd}" )
fi
# | jq "${jqfilter}" | read -r -d '' json

overrides=$(jq -n "${jqfilter}")
#exit

kubectl -n ${namespace} run -i --rm ${podName} --image="${baseImage}"  --overrides="${overrides}" 2>/dev/null

