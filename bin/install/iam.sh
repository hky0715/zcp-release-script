#!/bin/bash

pod=$(kubectl get pod | grep 'zcp-oidc-postgresql' | grep -v 'backup' | awk '{print $1}')
secret=$(kubectl exec zcp-oidc-postgresql-c94cc488f-5kqs8 -- psql -c "select secret from client where realm_id = 'master' and client_id = 'master-realm';" -tA)

client_secret=$(echo -n $secret | base64)
. env.prop

# https://stackoverflow.com/a/42386902
# https://wiki.kldp.org/HOWTO/html/Adv-Bash-Scr-HOWTO/parameter-substitution.html
ls *.tpl | while read tpl; do
  out=${tpl%.tpl}.yaml
  eval "echo \"$(cat $tpl)\"" > $out
done
