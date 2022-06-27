#!/bin/bash

openssl ecparam -out /tmp/private.key -name prime256v1 -genkey -noout
openssl req -new -sha256 -key /tmp/private.key -out /tmp/server.csr -subj "/C=TW/L=Taipei/O=Ubiquiti Networks Inc./OU=devint/CN=camera.ubnt.dev/emailAddress=support@ubnt.com"
openssl x509 -req -sha256 -days 36500 -in /tmp/server.csr -signkey /tmp/private.key -out /tmp/public.key
cat /tmp/private.key /tmp/public.key > client.pem
rm -f /tmp/private.key /tmp/public.key /tmp/server.csr