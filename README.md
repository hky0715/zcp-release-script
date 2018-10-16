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
# > for all repo
bash tag.sh show      # print all diff
bash tag.sh tag       # delete and add new tag
bash tag.sh push      # push tag (-f, force)
# > for single repo
bash tag.sh show zcp-iam
bash tag.sh tag  zcp-iam
bash tag.sh push zcp-iam

# push docker images to ibm-registry
# 1. create image list : docker images | grep -e ^cloudzcp > images
# 2. need to login at ibm-registry
bash mig.sh images registry.au-syd.bluemix.net/cloudzcp/
```
