#!/bin/bash

# Set nginx certificate based on certificate uuid 
# of an entry in omv config database
# usage:
# omv-set-nginx-ssl-cert <uuid>

. /usr/share/openmediavault/scripts/helper-functions

uuid=$1

echo "Using cert ${uuid} for nginx TLS"
omv_config_update "/config/webadmin/enablessl" 1
omv_config_update "/config/webadmin/sslcertificateref" "${uuid}"

echo "Updating certs and nginx..."
omv-salt deploy run certificates nginx

systemctl restart nginx

exit 0