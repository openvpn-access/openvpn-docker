FROM ubuntu:18.04

# Install dependencies
RUN apt update -y \
    && apt upgrade -y \
    && apt install openvpn openssl -y

COPY . /opt/app
WORKDIR /opt/app

RUN mkdir /etc/openvpn/pki

EXPOSE 1194

RUN chmod +x docker-entrypoint.sh
ENTRYPOINT ./docker-entrypoint.sh \
                "$REQ_COUNTRY" \
                "$REQ_PROVINCE" \
                "$REQ_CITY" \
                "$REQ_ORG" \
                "$REQ_OU" \
                "$REQ_CN"