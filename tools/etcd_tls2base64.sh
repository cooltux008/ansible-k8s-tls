#!/bin/bash
cat > ../dev/group_vars/etcd <<-EOF
etcd_cert: $(cat ../ssl/kubernetes.pem|base64)
etcd_key: $(cat ../ssl/kubernetes-key.pem|base64)
etcd_ca: $(cat ../ssl/ca.pem|base64)
EOF
cat ../dev/group_vars/etcd
