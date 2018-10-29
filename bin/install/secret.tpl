apiVersion: v1
kind: Secret
metadata:
  name: zcp-iam-secret
  namespace: zcp-system
type: Opaque
data:
  KEYCLOAK_MASTER_CLIENT_SECRET: $client_secret
  KEYCLOAK_MASTER_USERNAME: $keycloak_user
  KEYCLOAK_MASTER_PASSWORD: $keycloak_pwd
  JENKINS_USER_TOKEN: $jenkins_user_token
