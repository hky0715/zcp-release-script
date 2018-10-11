```
cd bin

export version=1.0.0

# checkout
# > .repos : all repositories in cnpst
# > checkout.exclude : grep -v -f checkout.exclude
# > checkout.include : grep -f checkout.include
# > .target : a list for checkout
bash checkout.sh     # ls -al ../$version

# chart
# > chart.repo : dir names for change version (Chart.yaml)
bash chart.sh

# build
# > build.repo : dir names for build. support mvnw, yarn, docker
# > .images : base images. will be tagged for docker.io and ibm-registry.
bash build.sh     # docker images | grep $version | sort

# tag
bash tag.sh               # print all diff
bash tag.sh zcp-iam       # add, commit, tag
bash tag.sh zcp-iam push  # push commit and tag

# push docker images to ibm-registry
# 1. create image list : docker images | grep -e ^cloudzcp > images
# 2. need to login at ibm-registry
bash mig.sh images registry.au-syd.bluemix.net/cloudzcp/
```
