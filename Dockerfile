# Smallest base image
FROM alpine:3.4

MAINTAINER Pieter Lange <pieter@ptlc.nl>

RUN echo "http://dl-4.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    echo "http://dl-4.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk add --update openvpn iptables bash easy-rsa libintl inotify-tools && \
    apk add --virtual build_deps gettext &&  \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    ln -s /usr/share/easy-rsa/easyrsa /usr/local/bin && \
    apk del build_deps && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# Needed by scripts
ENV OPENVPN /etc/openvpn
ENV OVPN_TEMPLATE $OPENVPN/templates/openvpn.tmpl
ENV OVPN_CONFIG $OPENVPN/openvpn.conf

ENV OVPN_PORTMAPPING $OPENVPN/portmapping
ENV OVPN_CRL $OPENVPN/crl/crl.pem
ENV OVPN_CCD $OPENVPN/ccd
ENV OVPN_DEFROUTE 0

ENV EASYRSA /usr/share/easy-rsa
ENV EASYRSA_PKI $OPENVPN/pki

# Some PKI scripts.
ADD ./bin /usr/local/bin
RUN chmod a+x /usr/local/bin/*

# Initialisation scripts and default template
COPY entrypoint.sh /sbin/entrypoint.sh
COPY watch-portmapping.sh /sbin/watch-portmapping.sh
COPY openvpn.tmpl $OVPN_TEMPLATE

CMD ["/sbin/entrypoint.sh"]
