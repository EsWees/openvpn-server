#!/usr/bin/env bash

. varfile

### FOR Developrs use only!
docker rm -vf ${MSERVICE}-dev
rm -rf $(pwd)/tmp
docker run -d \
	--name ${MSERVICE}-dev \
	--privileged \
	-v $(pwd)/tmp:/etc/openvpn \
	-p 1194:1194 \
	-p 5555:5555 \
	-e SRV_ADDR="vpn" \
	-e SRV_PORT="1194" \
	-e SRV_PROTO="udp" \
	-e SRV_NET="10.0.47.0" \
	-e C="US fdf" \
	-e ST="NY fdf" \
	-e L="NewYork fff" \
	-e O="Test 1 df" \
	-e ODEF="Test server  df" \
	-e CN="root@localhost  dff" \
	-e SNAME="localhost " \
  ${MSERVICE}

