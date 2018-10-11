#!/bin/bash

project=build.repo
version=${version:-1.0.0}

REPO=`dirname $(pwd)`/$version

cat $project | while read proj; do
  cd $REPO/$proj
  if [ -f 'pom.xml' ]; then
    ./mvnw clean package
  elif [ -f 'package.json' ]; then
    yarn install && yarn run compile-aot
  fi
  echo ''
done

cat $project | while read proj; do
  DOCKER=`dirname $(find $REPO/$proj -name Dockerfile | head -n 1)`
  cd $DOCKER
  docker build . -t $proj:$version
  echo ''
done

docker images | grep -f $project | grep $version | grep -v '/' > .images

repository=registry.au-syd.bluemix.net/cloudzcp/
cat .images | awk -v registry="${repository:-$2}" '{
  image = $1;
  sub(/^[^\/]+\//, "", image);

  tag1 = $1 ":" $2
  tag2 = registry image ":" $2
  tag3 = "cloudzcp/" image ":" $2

  system("docker tag " tag1 " " tag2)
  system("docker tag " tag1 " " tag3)
}'

docker images | grep -f $project | sort
