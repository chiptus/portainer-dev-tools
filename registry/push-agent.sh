#!/bin/bash
set -euo pipefail
IFS=$'\n\t'



versions=("2.16.0" "2.16.1" "2.16.2" "2.16.3" "2.16.4") 

cd "$PORTAINER_HOME/agent"

for version in "${versions[@]}"
do
    echo "Building version $version"
    AGENT_VERSION=$version ./dev.sh build -c --image-name localhost:5000/agent:$version
    docker push localhost:5000/agent:$version
done