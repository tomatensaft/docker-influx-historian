#!/bin/sh

# generate https for grafana and browser
printf "generate https self signed key"

openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 \
  -nodes -keyout historian.key \
  -out historian.crt \
  -subj "/CN=tomatensaft.com" \
  -addext "subjectAltName=DNS:tomatensaft.com,IP:192.168.1.153"

printf "set permission"
chmod -R 777 ../certs/*