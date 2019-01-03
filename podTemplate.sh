#!/bin/bash
set -e

PORT=$1
CPU=$2
MEMORY=$3
KUBE_NODE=$4

cat << EOF
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: fortio-echo-$PORT
  namespace: kube-test
spec:
  replicas: 1 # tells deployment to run 1 pods matching the template
  template: # create pods using pod definition in this template
    metadata:
      # a unique name is generated from the deployment name
      labels:
        app: echosrv
    spec:
      containers:
      - name: echosrv
        image: fortio/fortio.echosrv
        imagePullPolicy: Always # needed despite what is documented to really get latest
        args: ["-port", "${PORT}"]
        ports:
        - containerPort: ${PORT}
        resources:
          requests:
            cpu: ${CPU}
          limits:
            memory: ${MEMORY}Gi
      hostNetwork: true
      serviceAccount: fortio
      serviceAccountName: fortio
      nodeName: ${KUBE_NODE}
      tolerations:
      - effect: NoSchedule
        key: dedicated
        operator: Equal
        value: openstack
      - effect: NoExecute
        key: dedicated
        operator: Equal
        value: openstack
EOF
