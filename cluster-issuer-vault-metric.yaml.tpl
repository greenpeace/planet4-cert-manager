---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: vault-issuer
  namespace: cert-manager
spec:
  vault:
    path: >-
      ${VAULT_METRIC_PATH}
    server: >-
      ${VAULT_ADDRESS}
    caBundle:  >-
      ${CA_CRT}
    auth:
      kubernetes:
        role: my-app-1
        mountPath: /v1/auth/kubernetes
        secretRef:
          name: vault-issuer-token
          key: token
---