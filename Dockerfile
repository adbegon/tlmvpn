FROM debian:stretch-slim

# Update package list
RUN apt-get update


# Install dependencies
ENV DEPENDENCIES libssl1.1 libboost-system1.62.0 libboost-thread1.62.0 libboost-filesystem1.62.0 libboost-date-time1.62.0 libboost-program-options1.62.0 libboost-iostreams1.62.0 libcurl4-openssl-dev libminiupnpc10
ENV BUILD_DEPENDENCIES g++ git scons libssl-dev libboost-system-dev  libboost-thread-dev libboost-filesystem-dev libboost-date-time-dev libboost-program-options-dev libboost-iostreams-dev libminiupnpc-dev
# Get FreeLAN sources
# Compile FreeLAN
# Remove sources and dependencies
ENV FREELAN_BRANCH master CXX=g++
WORKDIR /opt/

RUN apt-get install -y $DEPENDENCIES $BUILD_DEPENDENCIES && \
    git clone https://github.com/freelan-developers/freelan.git /opt/freelan &&\
    cd /opt/freelan && git checkout $FREELAN_BRANCH &&\
    apt-get autoclean &&\
    cd /opt/freelan && scons install prefix=/usr/ &&\
    rm -rf /opt/freelan &&\
    apt-get autoremove -y --purge $BUILD_DEPENDENCIES &&\
    apt-get autoclean &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Profit !
EXPOSE 12000/udp 12000/tcp

CMD ["/usr/bin/freelan", "-f", "--tap_adapter.enabled=off", "--switch.relay_mode_enabled=yes"]
