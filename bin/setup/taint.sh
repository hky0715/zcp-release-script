#!/bin/bash

# usage: taint.sh -o

# fail_trap is executed if an error occurs.
fail_trap() {
  result=$?
  # print error message
  if [ "$result" != '0' ]; then
    echo -e "\nERROR ($result):"

    if [ "$cluster" == '' ]; then
      echo '  Failed to connect kubernetes context.'
      echo
      echo '  tip: kubectl config get-contexts'
      echo '       ibmcloud cs clusters'
      echo '       ibmcloud cs cluster-config <cluster-name>'

    elif [ "$ibm_result" != '0' ]; then
      echo "  Failed to get worker-pool($cluster)."

    elif [ "$wp_m" == '' ]; then
      echo "  Failed to get worker-pool(management)."
      echo "  Fix variable (REGX_M=\"${REGX_M}\")."
      echo
      echo "WORKER POOL:"
      sed -n "s/^\(.*\)$/  \1/p" $TEMP  # with left pad

    elif [ "$wp_l" == '' ]; then
      echo "  Failed to get worker-pool(logging)."
      echo "  Fix variable (REGX_L=\"${REGX_L}\")."
      echo
      echo "WORKER POOL:"
      sed -n "s/^\(.*\)$/  \1/p" $TEMP  # with left pad

    else  # unknown error
      echo "  Failed to taint."

    fi
  fi

  # cleanup
  rm -f $TEMP

  exit $result
}

# grep work-pool id with pipefail.
wp_id() { 
  # not working
  #   cat $TEMP | grep -E $REGX_L | awk '{print $2}' | read wp_l
  cat $TEMP | grep -E $1 | awk '{print $2}'
}

# stop any command is fail
trap "{ set +x; } 2>/dev/null && fail_trap" EXIT ERR
set -e -o pipefail


# CONST
TEMP=.$$
REGX_M='^mngt_'
REGX_L='^logging_'

# lookup context vars
overwrite=${1:+--overwrite}
cluster=$(kubectl config current-context)
( # ibmcloud command print error message at stdout
  trap "cat $TEMP" ERR
  ibmcloud cs region
  ibmcloud cs worker-pools --cluster ${cluster} > $TEMP
) && ibm_result=$?
wp_m=$(wp_id "$REGX_M")
wp_l=$(wp_id "$REGX_L")


# print executed command
set -x

# label
kubectl label node -l $overwrite ibm-cloud.kubernetes.io/worker-pool-id=$wp_m node-role.kubernetes.io/management=''
kubectl label node -l $overwrite ibm-cloud.kubernetes.io/worker-pool-id=$wp_m role=management
kubectl label node -l $overwrite ibm-cloud.kubernetes.io/worker-pool-id=$wp_l node-role.kubernetes.io/logging=''
kubectl label node -l $overwrite ibm-cloud.kubernetes.io/worker-pool-id=$wp_l role=logging

# taint
kubectl taint nodes -l $overwrite role=management management=true:NoSchedule
kubectl taint nodes -l $overwrite role=logging logging=true:NoSchedule

kubectl get node
