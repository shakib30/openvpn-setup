#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install OpenVPN and Easy-RSA
sudo apt install -y openvpn easy-rsa

# Make Easy-RSA directory
make-cadir ~/openvpn-ca
cd ~/openvpn-ca

# Set up the CA variables
cat <<EOT >> vars
set_var EASYRSA_REQ_COUNTRY    "US"
set_var EASYRSA_REQ_PROVINCE   "CA"
set_var EASYRSA_REQ_CITY       "SanFrancisco"
set_var EASYRSA_REQ_ORG        "OpenVPN"
set_var EASYRSA_REQ_EMAIL      "admin@yourdomain.com"
set_var EASYRSA_REQ_OU         "MyOrganizationalUnit"
EOT

# Build the CA
source vars
./clean-all
./build-ca --batch

# Build the server key and certificate
./build-key-server --batch server

# Generate Diffie-Hellman parameters
./build-dh

# Generate an HMAC key
openvpn --genkey --secret keys/ta.key

# Copy the server certificates and keys
sudo cp keys/{server.crt,server.key,ca.crt,dh.pem,ta.key} /etc/openvpn

# Create the server configuration file
cat <<EOT | sudo tee /etc/openvpn/server.conf
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
cipher AES-256-CBC
auth SHA256
comp-lzo
persist-key
persist-tun
status openvpn-status.log
verb 3
EOT

# Enable IP forwarding
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
sudo sysctl -p

# Configure UFW
sudo ufw allow 1194/udp
sudo ufw allow OpenSSH

sudo ufw disable
sudo ufw enable

# Enable and start OpenVPN
sudo systemctl start openvpn@server
sudo systemctl enable openvpn@server

