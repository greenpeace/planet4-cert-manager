---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: vault-issuer
  namespace: sandbox
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