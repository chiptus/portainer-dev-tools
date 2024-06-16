#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

ip=172.17.0.1

openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout certs/domain.key \
    -addext "subjectAltName = IP:$ip" \
    -x509 -days 365 -out certs/domain.crt