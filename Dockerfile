# Original credit: https://github.com/jpetazzo/dockvpn
# Based on the changes by Kyle Manna <kyle@kylemanna.com>
# (https://github.com/kylemanna/docker-openvpn)

FROM neingeist/fedora22_base
MAINTAINER Mike Gerber <mike@sprachgewalt.de>

RUN dnf -y update && dnf clean all

# Install OpenVPN
RUN dnf install -y openvpn git iptables procps-ng && dnf clean all

# Update checkout to use tags when v3.0 is finally released
RUN git clone --depth 1 --branch v3.0.0-rc2 https://github.com/OpenVPN/easy-rsa.git /usr/local/share/easy-rsa && \
    ln -s /usr/local/share/easy-rsa/easyrsa3/easyrsa /usr/local/bin

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV EASYRSA /usr/local/share/easy-rsa/easyrsa3
ENV EASYRSA_PKI $OPENVPN/pki
ENV EASYRSA_VARS_FILE $OPENVPN/vars

VOLUME ["/etc/openvpn"]

# Internally uses port 1194/udp, remap using `docker run -p 443:1194/tcp`
EXPOSE 1194/udp

WORKDIR /etc/openvpn
CMD ["ovpn_run"]

ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*
