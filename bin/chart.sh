#!/bin/bash

charts=chart.repo
version=${version:-1.0.0}

REPO=`dirname $(pwd)`/$version
REPO_CHART=$REPO/charts

cat $charts | while read chart; do
  sed -i -E "s/(version:) ?(.+)$/\1 $version/" $REPO/$chart/Chart.yaml
  cd $REPO/$chart && git diff
  echo ''
done

cat $charts | while read chart; do
  cd $REPO
  helm dependency build $chart
  helm package $chart -d $REPO_CHART/docs
  echo ''
done

cd $REPO_CHART
helm repo index docs --url https://cnpst.github.io/charts
git diff
