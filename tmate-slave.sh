#!/bin/sh

HOST=${HOST:-`hostname`}
PORT=${PORT:-2222}

# Create new keys if none exist.
if [[ ! -d /etc/tmate-keys ]]; then
  cd /tmp
  /bin/create_keys.sh
  mv /tmp/keys /etc/tmate-keys
fi

# Output the helpful stuff needed for tmate configuration.
RSA=`ssh-keygen -l -f /etc/tmate-keys/ssh_host_rsa_key -E md5 2>&1 | cut -d\  -f 2 | sed s/MD5://`
ECDSA=`ssh-keygen -l -f /etc/tmate-keys/ssh_host_ecdsa_key -E md5 2>&1 | cut -d\  -f 2 | sed s/MD5://`
echo Add this to your ~/.tmate.conf file
echo -----------------------------------
echo set -g tmate-server-host $HOST
echo set -g tmate-server-port $PORT
echo set -g tmate-server-rsa-fingerprint \"$RSA\"
echo set -g tmate-server-ecdsa-fingerprint \"$ECDSA\"
echo set -g tmate-identity \"\"              # Can be specified to use a different SSH key.
echo -----------------------------------

exec /bin/tmate-slave -h $HOST -p $PORT -k /etc/tmate-keys 2>&1
