FROM fedora:latest

LABEL description="Linux (Fedora) + OpenSSL + OpenVPN"
LABEL license="As is"
LABEL usage="docker run -d -p 1194:1194 -p 5555:5555 eswees/openvpn-server"
LABEL version="1.5"
LABEL maintainer="Yuriy Golik <eswees@pyhead.net>"

ENV SRV_ADDR=vpn.localhost
ENV SRV_PORT=1194
ENV SRV_PROTO=udp
ENV SRV_NET=10.0.27.0

ENV C=US
ENV ST=No
ENV L=Noname
ENV O=PyHead
ENV ODEF="PyHead and co."
ENV CN=root@localhost
ENV SNAME=localhost

EXPOSE 1194
EXPOSE 5555

WORKDIR /etc/openvpn/

RUN dnf install -y \
		openvpn \
		openssl \
	&& dnf clean all

COPY openvpn_init.sh /
RUN chmod +x /openvpn_init.sh

ENTRYPOINT [ "/openvpn_init.sh" ]

CMD [ "/usr/sbin/openvpn", "--config", "server.conf" ]
