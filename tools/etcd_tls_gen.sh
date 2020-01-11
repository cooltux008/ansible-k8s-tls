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
	      "server": {
		"usages": [
		    "signing",
		    "key encipherment",
		    "server auth",
		    "client auth"
		],
		"expiry": "87600h"
	      },
	      "client": {
		"usages": [
		    "signing",
		    "key encipherment",
		    "client auth"
		],
		"expiry": "87600h"
	      },
	      "peer": {
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
	cfssl gencert -initca ca-csr.json | cfssljson -bare etcd-ca -
}



function etcd_client_gen {
	cat > etcd-csr.json <<-EOF
	{
	  "CN": "etcd-client",
	  "hosts": [
	    "192.168.130.11",
	    "192.168.130.12",
	    "192.168.130.13",
	    "192.168.130.21",
	    "192.168.130.22",
	    "192.168.130.23",
	    "192.168.130.31",
	    "192.168.130.32",
	    "192.168.130.33",
	    "127.0.0.1",
	    "localhost"
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
	cfssl gencert -ca=etcd-ca.pem -ca-key=etcd-ca-key.pem -config=ca-config.json -profile=server etcd-csr.json | cfssljson -bare etcd-client
}


function etcd_peer_gen {
	cat > etcd-csr.json <<-EOF
	{
	  "CN": "etcd-peer",
	  "hosts": [
	    "192.168.130.11",
	    "192.168.130.12",
	    "192.168.130.13",
	    "192.168.130.21",
	    "192.168.130.22",
	    "192.168.130.23",
	    "192.168.130.31",
	    "192.168.130.32",
	    "192.168.130.33",
	    "127.0.0.1",
	    "localhost"
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
	cfssl gencert -ca=etcd-ca.pem -ca-key=etcd-ca-key.pem -config=ca-config.json -profile=peer etcd-csr.json | cfssljson -bare etcd-peer
}


function verify_pem {
	openssl x509  -noout -text -in  etcd-client.pem
	cfssl-certinfo -cert etcd-client.pem
}


mkdir -p ../tls/etcd
cd ../tls/etcd
#export CFSSL_URL="https://pkg.cfssl.org/R1.2"
export CFSSL_URL="http://192.168.130.1/ftp/linux_soft/cfssl/R1.2"
download_cfssl $CFSSL_URL
ca_gen
etcd_client_gen
etcd_peer_gen
verify_pem


rm -rf ca-config.json ca-csr.json config.json csr.json etcd-csr.json etcd-ca.csr etcd-client.csr etcd-peer.csr
