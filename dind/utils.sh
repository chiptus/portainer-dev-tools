#!/bin/bash
set -euo pipefail
IFS=$'\n\t'


function load_image() {
    local image_name=$1
    local url=${2:-''}
    local node_ips=("${@:3}")

    if [ -z "$url" ]; then
        return 0
    fi
    
    msg "Exporting image to machine..."
    docker save "${image_name}" -o "/tmp/portainer-agent.tar"
    docker -H "$url" rmi -f "${image_name}" || true
    docker -H "$url" load -i "/tmp/portainer-agent.tar"
    
    if [ ${#node_ips[@]} -eq 0 ]; then
        return 0
    fi
    
    msg "Exporting image to nodes..."
    for node_ip in "${node_ips[@]}"; do
        docker -H "${node_ip}:2375" rmi -f "${image_name}" || true
        docker -H "${node_ip}:2375" load -i "/tmp/portainer-agent.tar"
    done
}

#!/usr/bin/env bash

function setup_colors() {
    if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
        NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
    else
        NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
    fi
}

function msg() {
    echo >&2 -e "${1-}"
}

function die() {
    local msg=$1
    local code=${2-1} # default exit status 1
    msg "$msg"
    exit "$code"
}