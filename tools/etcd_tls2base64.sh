#!/bin/bash
mkdir -p ../dev/group_vars
cat > ../dev/group_vars/etcd <<-EOF
etcd_cert: $(cat ../tls/etcd/server.pem|base64)
etcd_key: $(cat ../tls/etcd/server-key.pem|base64)
etcd_ca: $(cat ../tls/etcd/ca.pem|base64)
EOF
cat ../dev/group_vars/etcd
