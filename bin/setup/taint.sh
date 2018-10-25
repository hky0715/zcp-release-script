#!/bin/sh
cluster=$(kubectl config current-context)

ibmcloud cs worker-pools --cluster $cluster > .worker-pools.$cluster
cat .worker-pools.$cluster

wp_mng=$(cat .worker-pools.$cluster | grep -E '^mngt_' | awk '{print $2}')
wp_log=$(cat .worker-pools.$cluster | grep -E '^logging_' | awk '{print $2}')
echo "kubectl label node -l ibm-cloud.kubernetes.io/$wp_mng node-role.kubernetes.io/management=''"
echo "kubectl label node -l ibm-cloud.kubernetes.io/$wp_log node-role.kubernetes.io/logging=''"
echo "kubectl label node -l ibm-cloud.kubernetes.io/$wp_mng role/management"
echo "kubectl label node -l ibm-cloud.kubernetes.io/$wp_log role/logging"

kubectl get node

# taint
kubectl taint nodes -l role=management management=true:NoSchedule
kubectl taint nodes -l role=logging logging=true:NoSchedule