#!/bin/bash
keycloak_user=cloudzcp-iam
keycloak_pwd=
jenkins_user=username
jenkins_token=api-token

domain_prefix=pou-
api_server=kubernetes.default

# for secret
keycloak_user=$(echo -n $keycloak_user | base64)
keycloak_pwd=$(echo -n $keycloak_pwd | base64)
jenkins_user_token=$(echo -n $jenkins_user:$jenkins_token | base64)

pod=$(kubectl get pod | grep 'zcp-oidc-postgresql' | grep -v 'backup' | awk '{print $1}')
secret=$(kubectl exec $pod -- psql -c "select secret from client where realm_id = 'master' and client_id = 'master-realm';" -tA)
client_secret=$(echo -n $secret | base64)