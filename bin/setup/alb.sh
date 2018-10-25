#!/bin/sh
cluster=$(kubectl config current-context)

ic cs albs --cluster $cluster > .alb.$cluster
cat .alb.$cluster

private_alb=$(cat .alb.$cluster | grep -E '^private-' | awk '{print $1}')

ic cs alb-configure --albID $private_alb --enable

#TODO: create alb2

#TODO: check vlans & subnets policy
ic ks vlans seo01 > .vlans.$cluster
cat .vlans.#cluster
#vlan=$(cat .vlans.$cluster)
#ic cs cluster-subnet-create --cluster $cluster --size 64 --vlan $vlan
#ic cs subnets