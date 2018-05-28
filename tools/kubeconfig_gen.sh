#!/bin/bash


export tls_dir='../ssl'


export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
cat > $tls_dir/token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF



export KUBE_APISERVER="https://192.168.130.11:6443"

################################################
## kubeconfig=$tls_dir/bootstrap.kubeconfig ##
################################################
# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=$tls_dir/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=$tls_dir/bootstrap.kubeconfig

# 设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=$tls_dir/bootstrap.kubeconfig

# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=$tls_dir/bootstrap.kubeconfig

# 设置默认上下文
kubectl config use-context default --kubeconfig=$tls_dir/bootstrap.kubeconfig

################################################
## kube-proxy.kubeconfig ##
################################################
# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=$tls_dir/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=$tls_dir/kube-proxy.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials kube-proxy \
  --client-certificate=$tls_dir/kube-proxy.pem \
  --client-key=$tls_dir/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=$tls_dir/kube-proxy.kubeconfig
# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=$tls_dir/kube-proxy.kubeconfig
# 设置默认上下文
kubectl config use-context default --kubeconfig=$tls_dir/kube-proxy.kubeconfig

################################################
## admin.kubeconfig ##
################################################
# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=$tls_dir/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=$tls_dir/admin.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials admin \
  --client-certificate=$tls_dir/admin.pem \
  --client-key=$tls_dir/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=$tls_dir/admin.kubeconfig
# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=admin \
  --kubeconfig=$tls_dir/admin.kubeconfig
# 设置默认上下文
kubectl config use-context default --kubeconfig=$tls_dir/admin.kubeconfig
