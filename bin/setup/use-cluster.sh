#!/bin/bash

log() {
  echo "$*"	
}

pad() {
  cat - | xargs -I{} echo "   {}"
}

install_ibmcloud() {
  log "ibmcloud : "
  if ! ibmcloud -v 2>/dev/null; then
    # https://console.bluemix.net/docs/cli/reference/ibmcloud/download_cli.html#install_use
    log 'Install ibmcloud CLI'
    curl -fsSL https://clis.ng.bluemix.net/install/linux | sh
    ibmcloud -v | pad
  fi
}

install_ibmcloud_cs() {
  if ! (log "ibmcloud cs : " && ibmcloud plugin list | grep container-service); then
    # https://console.bluemix.net/docs/containers/cs_cli_install.html#cs_cli_install_steps
    '+ install ibmcloud cs' | pad
    ibmcloud plugin install container-service -r Bluemix
    ibmcloud plugin list | pad
  fi
}

# Install kubectl CLI
install_kubectl() {
  if ! (log "kubectl" && kubectl version --client --short); then
    # https://kubernetes.io/docs/tasks/tools/install-kubectl/
    vkubectl=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
    log 'Install kubectl CLI ($vkubectl)'
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$vkubectl/bin/linux/amd64/kubectl
    chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl
    kubectl version --client --short | pad
  fi
}

# START Shell Script
#install_ibmcloud
#install_ibmcloud_cs
#install_kubectl

log 'Look up clusters'
#ibmcloud cs region
ibmcloud cs clusters -s > .clusters
if [ $? -ne 0 ]; then
  cat .clusters
  return 0
fi
if [ $(cat .clusters | grep '\S' | wc -l) -eq 0 ]; then
  log "err: There is no clusters."
  return 0
fi

# select cluster name
cat .clusters && read -p "Which index of cluster to use? " index
[ -n "${index//[0-9]+/}" ] || (echo "error: Not a number", exit 1)

cluster=$(sed -n "$((index+2))p" .clusters | cut -f1 -d' ')

ibmcloud cs cluster-config $cluster | tee .clusters
cmd=$(cat .clusters | tail -1)
$cmd

kubectl config get-contexts
