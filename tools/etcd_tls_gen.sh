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

function etcd_gen {
	cfssl print-defaults config > config.json
	cfssl print-defaults csr > csr.json
	cat > ca-config.json <<-EOF
	{
	  "signing": {
	    "default": {
	      "expiry": "87600h"
	    },
	    "profiles": {
	      "etcd": {
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
	  "CN": "etcd CA",
	  "key": {
	    "algo": "rsa",
	    "size": 2048
	  },
	  "names": [
	    {
	      "C": "CN",
	      "ST": "BeiJing",
	      "L": "BeiJing"
	    }
	  ]
	}
	EOF

	cat > server-csr.json <<-EOF
	{
	    "CN": "etcd",
	    "hosts": [
	      "192.168.130.11",
	      "192.168.130.12",
	      "192.168.130.13",
	      "127.0.0.1"
	    ],
	    "key": {
		"algo": "rsa",
		"size": 2048
	    },
	    "names": [
		{
		    "C": "CN",
		    "ST": "BeiJing",
		    "L": "BeiJing"
		}
	    ]
	}
	EOF
	cfssl gencert -initca ca-csr.json | cfssljson -bare ca -
	cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=etcd server-csr.json | cfssljson -bare server
}



function verify_pem {
	openssl x509  -noout -text -in  server.pem
	cfssl-certinfo -cert server.pem
}


mkdir -p ../tls/etcd
cd ../tls/etcd
#export CFSSL_URL="https://pkg.cfssl.org/R1.2"
export CFSSL_URL="http://192.168.130.1/ftp/linux_soft/cfssl/R1.2"
download_cfssl $CFSSL_URL
etcd_gen
verify_pem
