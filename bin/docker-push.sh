#!/bin/bash

docker login
docker images | grep -e ^cloudzcp | awk '{print $1 ":" $2}' | xargs -I{} docker push {}