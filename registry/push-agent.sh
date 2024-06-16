#!/bin/bash
set -euo pipefail
IFS=$'\n\t'



versions=("2.16.0" "2.16.1" "2.16.2")
# "2.16.3" "2.16.4") 
registry="172.17.0.1:5000"

cd "$PORTAINER_HOME/agent"

for version in "${versions[@]}"
do
    echo "Building version $version"
    image_name=$registry/agent:$version
    AGENT_VERSION=$version ./dev.sh build -c --image-name $image_name
    docker push $image_name
done