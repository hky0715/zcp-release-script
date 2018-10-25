#!/bin/sh

if [ "$(which helm)" == '' ]; then
  # https://github.com/helm/helm/blob/master/docs/install.md#from-script
  # https://stackoverflow.com/a/25563308
  curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | sudo sh -s -- -v v2.9.1
fi

kubectl config get-contexts

# create Namespace
kubectl create namespace zcp-system
kubectl label ns zcp-system cloudz-system-ns="true"

# create StorageClass
helm repo add ibm https://registry.bluemix.net/helm/ibm
helm install --name ibm-block-storage-plugin --namespace kube-system ibm/ibmcloud-block-storage-plugin

# create ClusterRole
kubectl get clusterrole view -o yaml > member-cluster-role.yaml
sed "s/$  name:.*$/  name: member/" member-cluster-role.yaml

kubectl get clusterrole edit -o yaml > cicd-manager-namespace-role.yaml
sed "s/$  name:.*$/  name: cicd-manager/" cicd-manager-namespace-role.yaml

kubectl get clusterrole view -o yaml > developer-namespace-role.yaml
sed "s/$  name:.*$/  name: cicd-manager/" developer-namespace-role.yaml

ls *-role.yaml | xargs -I{} kubectl create -f {}

# labeling ClusterRole
kubectl label clusterrole cluster-admin cloudzcp.io/zcp-system-cluster-role=true
kubectl label clusterrole member        cloudzcp.io/zcp-system-cluster-role=true
kubectl label clusterrole admin         cloudzcp.io/zcp-system-namespace-role=true
kubectl label clusterrole cicd-manager  cloudzcp.io/zcp-system-namespace-role=true
kubectl label clusterrole developer     cloudzcp.io/zcp-system-namespace-role=true

# labeling Namespace
kubectl label ns default cloudzcp.io/zcp-system=true

# create Secret
kubectl create secret docker-registry bluemix-cloudzcp-secret \
  --docker-server=registry.au-syd.bluemix.net \
  --docker-password=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJqdGkiOiI2MzZlNmQzNS1jYjZiLTUwMWItODhmNS0wNWViODBiMWQ2MGIiLCJpc3MiOiJyZWdpc3RyeS5hdS1zeWQuYmx1ZW1peC5uZXQifQ.3kacnFvrjx-mJfRg85nxeJlKqxNgiqap8rHGZmVTr_A \
  --docker-username=token \
  --docker-email=token \
  -n zcp-system
kubectl edit sa -n zcp-system default

#kubectl get sa -n zcp-system default -o yaml > sa.yaml
#echo -e "imagePullSecrets: \n- name: bluemix-cloudzcp-secret" > sa.yaml
#kubectl apply -f sa.yaml