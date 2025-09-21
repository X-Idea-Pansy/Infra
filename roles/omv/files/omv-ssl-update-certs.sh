#!/bin/bash

# Load and set SSL cert as openmediavault main certificate, apply changes
# to Nginx conf and restart Nginx
# usage:
# omv-ssl-update-certs <uuid> <cert_path> <key_path>

. /usr/share/openmediavault/scripts/helper-functions

uuid=$1
cert=$2
key=$3

subject=$(openssl x509 -inform PEM -in $cert -noout -subject -nameopt compat | sed 's/subject=//')
if [ "${subject}" == "" ]; then
    echo "Failed to extract subject from intermediary certificate $cert"
    exit 1
fi

if ! omv_isuuid "${uuid}"; then
    echo "Invalid uuid"
    exit 1
fi

if [ ! -f "${cert}" ]; then
    echo "Cert not found"
    exit 2
fi

if [ ! -f "${key}" ]; then
    echo "Key not found"
    exit 3
fi

echo "Cert file :: ${cert}"
echo "Key file :: ${key}"

xpath="/config/system/certificates/sslcertificate[uuid='${uuid}']"
echo "xpath :: ${xpath}"
echo "writing certificate $cert subject $subject under uuid: $uuid"

if ! omv_config_exists "${xpath}"; then
    echo "Config for ${uuid} does not exist: creating"
    cert_content=$(awk '{printf "%s\\n", $0}' $cert)
    key_content=$(awk '{printf "%s\\n", $0}' $key)

    omv_config_add_node_data "/config/system/certificates" "sslcertificate" \
        "<uuid>${uuid}</uuid><certificate>${cert_content}</certificate><privatekey>${key_content}</privatekey><comment>${subject}</comment>"
    echo "Config created successfully"
else
    echo "Updating certificate in database ..."
    omv_config_update "${xpath}/certificate" "$(cat ${cert})"

    echo "Updating private key in database ..."
    omv_config_update "${xpath}/privatekey" "$(cat ${key})"

    echo "Updating comment in database ..."
    omv_config_update "${xpath}/comment" "${subject}"
fi

exit 0