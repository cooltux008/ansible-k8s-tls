#!/bin/bash

function download_cfssl {
    for i in cfssl cfssljson cfssl-certinfo
    do
        if [ "$(uname)" == "Linux" ];then
            curl $1/${i}_linux-amd64 -o /usr/bin/$i
            chmod +x /usr/bin/$i
        elif [ "$(uname)" == "Darwin" ];then
            curl $1/${i}_darwin-amd64 -o /usr/local/bin/$i
            chmod +x /usr/local/bin/$i
	fi
    done
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
	      "aggregator": {
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
	  "CN": "aggregator CA",
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
	cfssl gencert -initca ca-csr.json | cfssljson -bare aggregator-ca -
}



function aggregator_gen {
	cat > aggregator-csr.json <<-EOF
	{
	  "CN": "aggregator",
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
	cfssl gencert -ca=aggregator-ca.pem -ca-key=aggregator-ca-key.pem -config=ca-config.json -profile=aggregator aggregator-csr.json | cfssljson -bare aggregator
}


function verify_pem {
	openssl x509  -noout -text -in  aggregator.pem
	cfssl-certinfo -cert aggregator.pem
}


mkdir -p ../tls/kubernetes
cd ../tls/kubernetes
#export CFSSL_URL="https://pkg.cfssl.org/R1.2"
export CFSSL_URL="http://192.168.8.1/ftp/linux_soft/cfssl/R1.2"
download_cfssl $CFSSL_URL
ca_gen
aggregator_gen
verify_pem


rm -rf ca-config.json ca-csr.json config.json csr.json aggregator-ca.csr aggregator.csr aggregator-csr.json
