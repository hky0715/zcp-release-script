#!/bin/bash

NS=ns-setup-test

# print current context
kubectl config get-contexts && echo

# create Namespace
kubectl create ns $NS
kubectl label ns $NS cloudz-system-ns="true"

# labeling Namespace
kubectl label ns default cloudzcp.io/zcp-system=true

# create StorageClass
if [ "$(which helm)" == '' ]; then
  # https://github.com/helm/helm/blob/master/docs/install.md#from-script
  # https://stackoverflow.com/a/25563308
  curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | sudo sh -s -- -v v2.9.1
  echo 
fi
if [ "$(helm ls ibm-block-storage-plugin)" == "" ]; then
  helm repo add ibm https://registry.bluemix.net/helm/ibm
  helm install --name ibm-block-storage-plugin --namespace kube-system ibm/ibmcloud-block-storage-plugin
fi

# create ClusterRole
kubectl get clusterrole view -o yaml > member-cluster-role.yaml
sed -ie "s/^  name:.*$/  name: member/" member-cluster-role.yaml

kubectl get clusterrole edit -o yaml > cicd-manager-namespace-role.yaml
sed -ie "s/^  name:.*$/  name: cicd-manager/" cicd-manager-namespace-role.yaml

kubectl get clusterrole view -o yaml > developer-namespace-role.yaml
sed -ie "s/^  name:.*$/  name: developer/" developer-namespace-role.yaml

ls *-role.yaml | xargs -I{} kubectl create -f {}

# labeling ClusterRole
kubectl label clusterrole cluster-admin cloudzcp.io/zcp-system-cluster-role=true
kubectl label clusterrole member        cloudzcp.io/zcp-system-cluster-role=true
kubectl label clusterrole admin         cloudzcp.io/zcp-system-namespace-role=true
kubectl label clusterrole cicd-manager  cloudzcp.io/zcp-system-namespace-role=true
kubectl label clusterrole developer     cloudzcp.io/zcp-system-namespace-role=true

# create Docker Secret
kubectl create secret docker-registry bluemix-cloudzcp-secret \
  --docker-server=registry.au-syd.bluemix.net \
  --docker-password=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI2MzZlNmQzNS1jYjZiLTUwMWItODhmNS0wNWViODBiMWQ2MGIiLCJpc3MiOiJyZWdpc3RyeS5hdS1zeWQuYmx1ZW1peC5uZXQifQ.3kacnFvrjx-mJfRg85nxeJlKqxNgiqap8rHGZmVTr_A \
  --docker-username=token \
  --docker-email=token \
  -n $NS

kubectl get sa default -o yaml -n $NS > sa-$NS-default.yaml
has_secret=$(cat sa-$NS-default.yaml | grep bluemix-cloudzcp-secret | wc -l)
if (( has_secret == 0 )); then
  echo -e "imagePullSecrets: \n- name: bluemix-cloudzcp-secret" >> sa-$NS-default.yaml
  kubectl apply -f sa-$NS-default.yaml
fi