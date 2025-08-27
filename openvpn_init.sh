#!/usr/bin/env bash
### --- DEBUG
set -u
set -e
# set -x
### System REQ.:
_country="${C/[[:space:]]*/}"
_state="${ST/[[:space:]]*/}"
_location="${L/[[:space:]]*/}"
_org_name="${O/[[:space:]]*/}"
_org_unit="${ODEF/[[:space:]]*/}"
_contact_name="${CN/[[:space:]]*/}"
_server_name="${SNAME/[[:space:]]*/}"
############################################################################################################################
### CONFIG ### CONFIG ### CONFIG ### CONFIG ### CONFIG ### CONFIG ### CONFIG ### CONFIG ### CONFIG ### CONFIG ### CONFIG ###
############################################################################################################################
DST="users_bundle"
SRV_CRT="certs/server.crt"
SRV_KEY="keys/server.key"
CRL_CRT="crl/crl.pem"
PRV_KEY="private/CA.key"
CA_CRT="CA.crt"
CA_CSR="req/server.csr"
dh2048="dh2048.pem"
TA_KEY="ta.key"
DEV="tun10"
PROTO=${SRV_PROTO:-tcp}
REM_ADDR=${SRV_ADDR:-10.28.0.1}
CONF_NAME="${O/[[:space:]]*/}"
DIR="${CONF_NAME}_server"
############################################################################################################################
### CONFIG ### CONFIG ### CONFIG ### CONFIG ### CONFIG ### CONFIG ### CONFIG ### CONFIG ### CONFIG ### CONFIG ### CONFIG ###
############################################################################################################################
# ---
## Fix missing devices for newer docker image
mkdir -p /dev/net
mknod /dev/net/tun c 10 200
chmod 600 /dev/net/tun
# ---
if [ ! -d ${DIR} ] || [ ! -d ${DST} ]; then
	mkdir -p ${DST} ${DIR}
fi
cd ${DIR}
# ---
dir_list="ccd certs crl keys private req"
for dir_each in ${dir_list}; do
	if [ ! -d ${dir_each} ]; then
		mkdir ${dir_each}
	fi
done
# ---
chmod 700 -R keys private
# ---
if [ ! -f serial ]; then
	echo "01" > serial
fi
# ---
files_must_exist="index.txt openssl.cnf"
for files_each in ${files_must_exist}; do
	if [ ! -f ${files_each} ]; then
		touch ${files_each}
	fi
done
echo 'unique_subject = no' > index.txt.attr
# ---
if [ ! -s openssl.cnf ]; then
	echo '[ ca ]
default_ca               = CA_default
[ CA_default ]
dir                      = /etc/openvpn/'$DIR'
crl_dir                  = $dir/crl
database                 = $dir/index.txt
new_certs_dir            = $dir/certs
certificate              = $dir/'$CA_CRT'
serial                   = $dir/serial
crl                      = $dir/'$CRL_CRT'
private_key              = $dir/'$PRV_KEY'
RANDFILE                 = $dir/private/.rand
default_days             = 3650
default_crl_days         = 3650
default_md               = sha256
unique_subject           = yes
policy                   = policy_any
x509_extensions          = user_extensions
[ policy_any ]
organizationName         = match
organizationalUnitName   = optional
commonName               = supplied
[ req ]
default_bits             = 2048
default_keyfile          = privkey.pem
distinguished_name       = req_distinguished_name
x509_extensions          = CA_extensions
[ req_distinguished_name ]
organizationName         = '$_org_name'
organizationName_default = '$_org_unit'
organizationalUnitName   = '$_server_name'
commonName               = '$_contact_name'
commonName_max           = 64
[ user_extensions ]
basicConstraints         = CA:FALSE
[ CA_extensions ]
basicConstraints         = CA:TRUE
default_days             = 3650
[ server ]
basicConstraints         = CA:FALSE
nsCertType               = server
' > /etc/openvpn/${DIR}/openssl.cnf
fi
# ---
if [ ! -f $PRV_KEY ] || [ ! -f $SRV_CRT ]; then
	openssl req -new -nodes -x509 -keyout $PRV_KEY -out $CA_CRT -days 3650 -subj /C=${_country}/ST=${_state}/L=${_location}/O=${_org_name}/CN=${_contact_name}
	openssl req -new -nodes -keyout $SRV_KEY -out $CA_CSR -subj /C=${_country}/ST=${_state}/L=${_location}/O=${_org_name}/CN=${_contact_name}
	chmod g-r $SRV_KEY
	openssl ca -batch -config openssl.cnf -extensions server -out $SRV_CRT -infiles $CA_CSR
  chmod 600 $PRV_KEY
fi
if [ ! -f $CRL_CRT ]; then
	openssl ca -config openssl.cnf -gencrl -out $CRL_CRT
fi
# ---
if [ ! -f $TA_KEY ]; then
	openvpn --genkey secret $TA_KEY
fi
# ---
if [ ! -f $dh2048 ]; then
    openssl dhparam -out $dh2048 2048
fi
cd ../
if [ ! -f server.conf ]; then
	echo 'dh '$DIR'/'$dh2048'
ca '$DIR'/'$CA_CRT'
cert '$DIR'/'$SRV_CRT'
key '$DIR'/'$SRV_KEY'
crl-verify '$DIR'/'$CRL_CRT'
tls-auth '$DIR'/'$TA_KEY' 0
dev '$DEV'
proto '$PROTO'
server '$SRV_NET' 255.255.255.0
client-config-dir '$DIR'/ccd
client-to-client
tls-server
keepalive 10 120
tun-mtu 1500
mssfix 1450
persist-key
persist-tun
verb 3
management 0.0.0.0 5555
client-connect '${DIR}'/on_connect.sh
client-disconnect '${DIR}'/on_disconnect.sh
script-security 3
' > server.conf
fi
if [ ! -f ${DIR}/on_connect.sh ] || [ ! -f ${DIR}/on_disconnect.sh ]; then
	for files_connection in ${DIR}/on_connect.sh ${DIR}/on_disconnect.sh; do
		echo '#!/usr/local/env bash' > $files_connection
	done
fi
if [ ! -x ${DIR}/on_connect.sh ] || [ ! -x ${DIR}/on_disconnect.sh ]; then
	chmod +x ${DIR}/on_connect.sh ${DIR}/on_disconnect.sh
fi
# ---
if [ ! -f openvpn_adduser_$CONF_NAME ]; then
	echo '#!/usr/bin/bash
set -e
set -u
: ${1?E_NOPARAM}
pushd $(dirname $0)/'${DIR}'
if [ "$1" != "" ]; then
        openssl req -new -nodes -keyout keys/${1/[[:space:]]*/}.key -out req/${1/[[:space:]]*/}.csr -subj /C='${_country}'/ST='${_state}'/L='${_location}'/O='${_org_name}'/CN='${_contact_name}' 2>&1 > /dev/null
        openssl ca -batch -config openssl.cnf -out certs/${1/[[:space:]]*/}.crt -infiles req/${1/[[:space:]]*/}.csr 2>&1 > /dev/null
        openssl ca -config openssl.cnf -gencrl -out crl/crl.pem 2>&1 > /dev/null
        touch ccd/$1
        mkdir -p ../'${DST}'/${1/[[:space:]]*/}
        cp CA.crt       ../'${DST}'/${1/[[:space:]]*/}
        cp ta.key       ../'${DST}'/${1/[[:space:]]*/}
        cp certs/$1.crt ../'${DST}'/${1/[[:space:]]*/}
        cp keys/$1.key  ../'${DST}'/${1/[[:space:]]*/}

        echo "client
remote '$SRV_ADDR:$SRV_PORT'
proto '$PROTO'
dev '$DEV'
tls-client
ca CA.crt
cert ${1/[[:space:]]*/}.crt
key ${1/[[:space:]]*/}.key
tls-auth ta.key 1
ns-cert-type server
comp-lzo
keepalive 10 120
mssfix 1450
tun-mtu 1500" > ../'${DST}'/${1/[[:space:]]*/}/'$CONF_NAME'.conf

        echo "client
remote          '$SRV_ADDR:$SRV_PORT'
proto           '$PROTO'
dev             '$DEV'
tls-client
ns-cert-type    server
comp-lzo
key-direction   1
keepalive       10 120
mssfix          1450
tun-mtu         1500
<ca>
$(cat CA.crt)
</ca>
<cert>
$(sed -n "/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p" certs/${1/[[:space:]]*/}.crt)
</cert>
<key>
$(cat keys/${1/[[:space:]]*/}.key)
</key>
<tls-auth>
$(cat ta.key)
</tls-auth>
" > ../'${DST}'/${1/[[:space:]]*/}/'$CONF_NAME'.ovpn

        echo "OK! Files to user ${1/[[:space:]]*/} in
        ../'${DST}'/$1
        where
        CA_cert.pem - Server cert
        ta.key - Server key file from server cert
        ${1/[[:space:]]*/}.crt - Client cert
        ${1/[[:space:]]*/}.key - Client key file from client cert
        '$CONF_NAME'.conf - Client config for ${1/[[:space:]]*/}
        '$CONF_NAME'.ovpn - Client config for ${1/[[:space:]]*/} (OneFile configuration)"
else
        echo " -- Please provide username in argument! Ex: $(basename $0) name"
fi
popd
' > adduser_openvpn_$CONF_NAME
fi
# ---
if [ ! -f deluser_openvpn_$CONF_NAME ]; then
	echo '#!/usr/bin/bash
set -e
set -u
pushd $(dirname $0)/'${DIR}'
if [ "${1/[[:space:]]*/}" != "" ]; then
	openssl ca -keyfile '$SRV_KEY' -cert '$SRV_CRT' -revoke certs/${1/[[:space:]]*/}.crt -out req/${1/[[:space:]]*/}.crt -config openssl.cnf
	openssl ca -config openssl.cnf -gencrl -out '$CRL_CRT'
	rm -rf ../'${DST}'/${1/[[:space:]]*/} ../'${DST}'/${1/[[:space:]]*/}.tar ccd/${1/[[:space:]]*/}
else
	echo " -- Please provide username in argument! Ex: $(basename $0) name"
fi
popd
' > ${DIR}/../deluser_openvpn_$CONF_NAME
fi
# ---
if [ ! -x adduser_openvpn_$CONF_NAME ] || [ ! -x deluser_openvpn_$CONF_NAME ]; then
	chmod +x adduser_openvpn_$CONF_NAME deluser_openvpn_$CONF_NAME
fi
# ---
if [ ! -f users_bundle/client/$CONF_NAME.ovpn ]; then
	bash ./adduser_openvpn_$CONF_NAME client
fi
$@
