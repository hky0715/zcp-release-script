apiVersion: v1
kind: ConfigMap
metadata:
  name: zcp-iam-config
  namespace: zcp-system
data:
  SPRING_ACTIVE_PROFILE: stage
  KEYCLOAK_MASTER_REALM: master
  KEYCLOAK_MASTER_CLIENTID: master-realm
  KEYCLOAK_SERVER_URL: https://${domain_prefix}iam.cloudzcp.io/auth/
  KUBE_APISERVER_URL: https://${api_server}
  JENKINS_SERVER_URL: https://${domain_prefix}jenkins.cloudzcp.io
  JENKINS_TEMPLATE_PATH: classpath:jenkins/folder.xml
