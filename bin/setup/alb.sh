#!/bin/sh

# fail_trap is executed if an error occurs.
fail_trap() {
  { set +x; } 2>/dev/null

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
      echo "  Failed to get alb($cluster)."

    elif [ "$private_alb" == '' ]; then
      echo "  Failed to get private alb id."
      echo
      echo "ALB:"
      sed -n "s/^\(.*\)$/  \1/p" $TEMP  # with left pad

    else  # unknown error
      echo "  Failed to alb."

    fi
  fi

  # cleanup
  rm -f $TEMP

  exit $result
}

# stop any command is fail
trap "{ set +x; } 2>/dev/null && fail_trap" EXIT ERR
set -e -o pipefail

# CONST
TEMP=.$$

# lookup context vars
cluster=$(kubectl config current-context)
( # ibmcloud command print error message at stdout
  trap "cat $TEMP" ERR
  ibmcloud cs region
  ibmcloud cs albs --cluster ${cluster} > $TEMP
  cat $TEMP && echo
) && ibm_result=$?
private_alb=$(cat $TEMP | grep -E '^private-' | awk '{print $1}')

# print executed command
set -x
( ibmcloud cs alb-configure --albID $private_alb --enable || exit 0 )

#TODO: create alb2

#TODO: check vlans & subnets policy
ibmcloud cs vlans seo01 > $TEMP
cat $TEMP
#vlan=$(cat .vlans.$cluster)
#ic cs cluster-subnet-create --cluster $cluster --size 64 --vlan $vlan
#ic cs subnets
