#!/bin/bash


export ssl_dir='.'


export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
cat > token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF



export KUBE_APISERVER="https://192.168.130.11:6443"

################################################
## kubeconfig=bootstrap.kubeconfig ##
################################################
# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=$ssl_dir/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=bootstrap.kubeconfig

# 设置客户端认证参数
kubectl config set-credentials kubelet-bootstrap \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=bootstrap.kubeconfig

# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig

# 设置默认上下文
kubectl config use-context default --kubeconfig=bootstrap.kubeconfig

################################################
## kube-proxy.kubeconfig ##
################################################
# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=$ssl_dir/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kube-proxy.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials kube-proxy \
  --client-certificate=$ssl_dir/kube-proxy.pem \
  --client-key=$ssl_dir/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig
# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig
# 设置默认上下文
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

################################################
## kubelet.kubeconfig ##
################################################
# 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=kubelet.kubeconfig
# 设置客户端认证参数
kubectl config set-credentials kubelet \
  --client-certificate=/etc/kubernetes/ssl/kubelet.pem \
  --client-key=/etc/kubernetes/ssl/kubelet-key.pem \
  --embed-certs=true \
  --kubeconfig=kubelet.kubeconfig
# 设置上下文参数
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet \
  --kubeconfig=kubelet.kubeconfig
# 设置默认上下文
kubectl config use-context default --kubeconfig=kubelet.kubeconfig
