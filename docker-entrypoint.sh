#!/bin/bash

cd /etc/openvpn/pki

if [[ ! -f ./private/openvpn-access.pem ]]; then
    # Setup the PKI
    mkdir -p private req crt

    # Need to to do this because without it, openssl throws errors
    touch /root/.rnd

    echo "Generating private key..."
    openssl genrsa -out private/openvpn-access.pem 4096

    echo "Generating main request..."
    openssl req -nodes -new -key private/openvpn-access.pem -out req/openvpn-access.csr -subj "/C=$1/ST=$2/L=$3/O=$4/OU=$5/CN=$6"

    echo "Generating CA public key..."
    openssl genrsa -out private/ca.pem 4096

    echo "Generating CA request..."
    openssl req -nodes -new -x509 -key private/ca.pem -out crt/ca.crt -subj "/CN=OpenVPN-Access Certificate Authority"

    echo "Signing vpn request..."
    openssl x509 -req -in req/openvpn-access.csr -CA crt/ca.crt -CAkey private/ca.pem -CAcreateserial -out crt/openvpn-access.crt

    echo "Generatinng ta secret..."
    openvpn --genkey --secret ta.key

    echo "Generating diphie hellman params..."
    openssl dhparam -out dh.pem 4096 &> /dev/null
else
    echo "PKI already exists!"
fi

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi

cd /etc/openvpn

echo "Copying configuration..."
cp /opt/app/server.conf .

echo "Configuring networking rules..."
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

echo "Starting OpenVPN server..."
/usr/sbin/openvpn --cd /etc/openvpn --script-security 2 --config /etc/openvpn/server.conf