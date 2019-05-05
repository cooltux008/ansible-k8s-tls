#!/bin/bash

function download_cfssl {
    if [ "$(uname)" == "Linux" ];then
        for i in cfssl cfssljson cfssl-certinfo
        do
            curl $1/${i}_linux-amd64 -o /usr/bin/$i
            chmod +x /usr/bin/$i
        done
    elif [ "$(uname)" == "Darwin" ];then
        for i in cfssl cfssljson cfssl-certinfo
        do
            curl $1/${i}_darwin-amd64 -o /usr/local/bin/$i
            chmod +x /usr/local/bin/$i
        done
    fi
}

function ca_gen {
	cfssl print-defaults config > config.json
	cfssl print-defaults csr > csr.json
	cat > ca-config.json <<-EOF
	{
	  "signing": {
	    "default": {
	      "expiry": "87600h"
	    },
	    "profiles": {
	      "kubernetes": {
		"usages": [
		    "signing",
		    "key encipherment",
		    "server auth",
		    "client auth"
		],
		"expiry": "87600h"
	      }
	    }
	  }
	}
	EOF

	cat > ca-csr.json <<-EOF
	{
	  "CN": "kubernetes",
	  "key": {
	    "algo": "rsa",
	    "size": 2048
	  },
	  "names": [
	    {
	      "C": "CN",
	      "ST": "BeiJing",
	      "L": "BeiJing",
	      "O": "k8s",
	      "OU": "System"
	    }
	  ],
	    "ca": {
	       "expiry": "87600h"
	    }
	}
	EOF
	cfssl gencert -initca ca-csr.json | cfssljson -bare ca
}



function kubernetes_gen {
	cat > kubernetes-csr.json <<-EOF
	{
	    "CN": "kubernetes",
	    "hosts": [
	      "192.168.130.11",
	      "192.168.130.12",
	      "192.168.130.13",
	      "192.168.130.14",
	      "192.168.130.15",
	      "192.168.130.16",
	      "127.0.0.1",
	      "10.254.0.1",
	      "kubernetes",
	      "kubernetes.default",
	      "kubernetes.default.svc",
	      "kubernetes.default.svc.cluster",
	      "kubernetes.default.svc.cluster.local"
	    ],
	    "key": {
		"algo": "rsa",
		"size": 2048
	    },
	    "names": [
		{
		    "C": "CN",
		    "ST": "BeiJing",
		    "L": "BeiJing",
		    "O": "k8s",
		    "OU": "System"
		}
	    ]
	}
	EOF
	cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes
}



function admin_gen {
	cat > admin-csr.json <<-EOF
	{
	  "CN": "admin",
	  "hosts": [],
	  "key": {
	    "algo": "rsa",
	    "size": 2048
	  },
	  "names": [
	    {
	      "C": "CN",
	      "ST": "BeiJing",
	      "L": "BeiJing",
	      "O": "system:masters",
	      "OU": "System"
	    }
	  ]
	}
	EOF
	cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin
}



function kube-proxy_gen {
	cat > kube-proxy-csr.json <<-EOF
	{
	  "CN": "system:kube-proxy",
	  "hosts": [],
	  "key": {
	    "algo": "rsa",
	    "size": 2048
	  },
	  "names": [
	    {
	      "C": "CN",
	      "ST": "BeiJing",
	      "L": "BeiJing",
	      "O": "k8s",
	      "OU": "System"
	    }
	  ]
	}
	EOF
	cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes  kube-proxy-csr.json | cfssljson -bare kube-proxy
}


function verify_pem {
	openssl x509  -noout -text -in  kubernetes.pem
	cfssl-certinfo -cert kubernetes.pem
}


mkdir ../ssl
cd ../ssl
#export CFSSL_URL="https://pkg.cfssl.org/R1.2"
export CFSSL_URL="http://192.168.130.1/ftp/linux_soft/cfssl/R1.2"
download_cfssl $CFSSL_URL
ca_gen
kubernetes_gen
admin_gen
kube-proxy_gen
verify_pem
