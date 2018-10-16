#!/bin/bash

version=${version:-1.0.0}
cmd=${1:-show}
filter=$2

REPO=`dirname $(pwd)`/$version

# print status of all repository
#  backup :: ls | xargs -I{} echo "echo ++++ {}; git -C {} tag; git -C {} diff --name-only; echo ''" | bash
cd $REPO
ls | grep "$filter" | while read proj; do
  echo ++++ $proj
  cd $REPO/$proj
  if [ "$cmd" == 'tag' ]; then
    git tag -d $version
    git tag -a $version -m "Cloud Z CP v$version"
  elif [ "$cmd" == 'push' ]; then
    git push -f origin $version
  elif [ "$cmd" == 'show' ]; then
    git tag
  fi

  echo ''
done;
