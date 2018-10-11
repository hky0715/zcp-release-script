#!/bin/bash

version=${version:-1.0.0}

REPO=`dirname $(pwd)`/$version

if [ "$1" == '' ]; then
  cd $REPO
  ls | xargs -I{} echo "echo ++++ {}; git -C {} diff --name-only; echo ''" | bash

  exit 0
fi

if [ -d "$REPO/$1" ]; then
  cd $REPO/$1
  git add --all
  git commit -m "prepare release: $version"
  git tag -d $version
  git tag -a $version -m "Release: $version"
  git tag

  if [ "$2" == 'push' ]; then
    git push
    git push origin $version
  fi
fi
