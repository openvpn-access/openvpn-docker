FROM ubuntu:18.04

# Install dependencies
RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install software-properties-common -y \
    && add-apt-repository ppa:ubuntu-toolchain-r/test -y \
    && apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install git wget openvpn openssl build-essential gcc-10 g++-10 -y 

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 20 --slave /usr/bin/g++ g++ /usr/bin/g++-10

WORKDIR /tmp

RUN wget https://downloads.mariadb.com/Connectors/c/connector-c-3.1.9/mariadb-connector-c-3.1.9-ubuntu-bionic-amd64.tar.gz -O mariadbcconnector.tar.gz
RUN tar xzf mariadbcconnector.tar.gz
RUN cp -r /tmp/$(ls | grep "mariadb-")/lib/mariadb /usr/lib/
RUN cp -r /tmp/$(ls | grep "mariadb-")/include/mariadb /usr/include/

RUN wget https://github.com/Kitware/CMake/releases/download/v3.18.0/cmake-3.18.0-Linux-x86_64.tar.gz -O cmake.tar.gz
RUN tar xzf cmake.tar.gz

RUN ls

WORKDIR /tmp
RUN git clone https://github.com/openvpn-access/authenticator.git
RUN mkdir authenticator/build
WORKDIR /tmp/authenticator/build
RUN /tmp/$(ls /tmp | grep "cmake-")/bin/cmake -DGENERATE_DOCUMENTATION=OFF .. && /tmp/$(ls /tmp | grep "cmake-")/bin/cmake --build . --target authenticator
RUN cp ./authenticator /etc/openvpn

COPY . /opt/app
WORKDIR /opt/app

RUN cp /opt/app/authenticator.yml /etc/openvpn/authenticator.yml

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