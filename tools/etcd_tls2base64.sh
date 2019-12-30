#!/bin/bash
mkdir -p ../dev/group_vars
cat > ../dev/group_vars/etcd <<-EOF
etcd_cert: $(cat ../tls/etcd/etcd-client.pem|base64)
etcd_key: $(cat ../tls/etcd/etcd-client-key.pem|base64)
etcd_ca: $(cat ../tls/etcd/etcd-ca.pem|base64)
EOF
cat ../dev/group_vars/etcd
