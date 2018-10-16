apiVersion: v1
kind: Secret
metadata:
  name: zcp-iam-secret
  namespace: zcp-system
type: Opaque
data:
  KEYCLOAK_MASTER_CLIENT_SECRET: $client_secret
  KEYCLOAK_MASTER_USERNAME: $(echo -n $keycloak_user | base64)
  KEYCLOAK_MASTER_PASSWORD: $(echo -n $keycloak_pwd | base64)
  JENKINS_USER_TOKEN: $(echo -n $jenkins_user:$jenkins_token | base64)
