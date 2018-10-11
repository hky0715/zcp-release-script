#!/bin/bash

exclude=checkout.exclude
include=checkout.include
version=${version:-1.0.0}

REPO=`dirname $(pwd)`/$version
mkdir -p $REPO

curl -s https://api.github.com/orgs/cnpst/repos?per_page=200 | jq ".[].clone_url" --raw-output > .repos
cat .repos | grep -v -f $exclude | grep -f $include > .target

cat .target | while read url; do
  cd $REPO
  git clone $url 
done

cd $REPO
ls | xargs -I{} git -C {} pull
