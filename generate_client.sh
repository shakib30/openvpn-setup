#!/bin/bash

# Create a directory for client configurations
mkdir -p ~/client-configs/keys
chmod -R 700 ~/client-configs

# Create the base configuration file
cat <<EOT > ~/client-configs/base.conf
client
dev tun
proto udp
remote your-server-ip 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
comp-lzo
verb 3
EOT

# Generate a client key and certificate
cd ~/openvpn-ca
source vars
./build-key --batch client

# Copy the client keys and certificates
cp keys/{client.crt,client.key,ca.crt,ta.key} ~/client-configs/keys/

# Create the client configuration file
cat <<EOT > ~/client-configs/client.ovpn
client
dev tun
proto udp
remote your-server-ip 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
auth SHA256
comp-lzo
verb 3
<ca>
$(cat ~/client-configs/keys/ca.crt)
</ca>
<cert>
$(cat ~/client-configs/keys/client.crt)
</cert>
<key>
$(cat ~/client-configs/keys/client.key)
</key>
<tls-auth>
$(cat ~/client-configs/keys/ta.key)
</tls-auth>
EOT
