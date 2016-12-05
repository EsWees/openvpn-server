FROM centos:latest

MAINTAINER Yuriy Golik <eswees@pyhead.net>

LABEL Description="Linux (CentOS) + OpenSSL + OpenVPN." \
      License="As is" \
      Usage="docker run -d -p 1194:1194 -p 5555:5555 eswees/openvpn-server" \
      Version="1.4"

ENV SRV_ADDR vpn.localhost
ENV SRV_PORT 1194
ENV SRV_PROTO udp
ENV SRV_NET 10.0.27.0

ENV C OOPS
ENV ST NO
ENV L Noname
ENV O PyHead
ENV ODEF PyHead and co.
ENV CN root@localhost
ENV SNAME localhost

EXPOSE 1194
EXPOSE 5555

WORKDIR /etc/openvpn/

RUN yum install -y epel-release && yum install -y \
		openvpn \
		openssl \
		mutt \
	&& yum clean all

COPY openvpn_init.sh /
RUN chmod +x /openvpn_init.sh

ENTRYPOINT [ "/openvpn_init.sh" ]

CMD [ "/usr/sbin/openvpn", "--config", "server.conf" ]
