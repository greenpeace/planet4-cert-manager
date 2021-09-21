---
kind: Secret
apiVersion: v1
metadata:
  name: clouddns-dns01-solver-svc-acct
  namespace: cert-manager
data:
  global-it-infrastructure.json: >-
    ${GREENPEACE_ORG_SVC_ACCOUNT}
type: Opaque
---