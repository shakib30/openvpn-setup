Step 1: Pull the OpenVPN Docker image
Pull the OpenVPN image from the Docker registry:

===== 1 =====

docker pull kylemanna/openvpn

=============
Step 2: Initialize the OpenVPN configuration
Create a directory to store the OpenVPN configuration files:

===== 2 =====

mkdir -p /srv/openvpn

=============

Initialize the configuration:

=============

docker run -v /srv/openvpn:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://YOUR-SERVER-IP-ADDRESS

Generate the server certificates:

docker run -v /srv/openvpn:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki

=============

Step 3: Start the OpenVPN server
Run the OpenVPN server container:

===== 3 =====

docker run -v /srv/openvpn:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn

=============

Step 4: Generate client configuration files
Generate client certificates and configuration files. Repeat this step for each client:

===== 4 =====

docker run -v /srv/openvpn:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full kota-andolan nopass

=============

Retrieve the client configuration file:

=============

docker run -v /srv/openvpn:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient CLIENT_NAME > CLIENT_NAME.ovpn

#CLIENT_NAME=== YOUR VPN NAME OR VPN COUNTRY NAME

=============

Step 5: Restart the server

===== 5 =====

#if you need your server Restar so you can use

docker restart $(docker ps -q --filter ancestor=kylemanna/openvpn)

user limit: 
# Maximum number of clients
max-clients 100

=============









