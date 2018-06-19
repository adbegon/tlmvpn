FROM debian:stretch-slim

# Update package list
RUN apt-get update && apt-get -y upgrade &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*


# Install dependencies
ENV DEPENDENCIES libssl1.1 libboost-system1.62.0 libboost-thread1.62.0 libboost-filesystem1.62.0 libboost-date-time1.62.0 libboost-program-options1.62.0 libboost-iostreams1.62.0 libcurl4-openssl-dev libminiupnpc10  libcurl-ocaml
ENV BUILD_DEPENDENCIES scons python libssl-dev libcurl4-openssl-dev libboost-system-dev libboost-thread-dev libboost-program-options-dev libboost-filesystem-dev libboost-iostreams-dev libminiupnpc-dev build-essential git libcurl-ocaml-dev
# Get FreeLAN sources
# Compile FreeLAN
# Remove sources and dependencies
ENV FREELAN_BRANCH=master CXX=g++
WORKDIR /opt/

RUN apt-get install -y $DEPENDENCIES && apt-get install -y $BUILD_DEPENDENCIES &&\
    git clone https://github.com/freelan-developers/freelan.git /opt/freelan &&\
    cd /opt/freelan &&\ 
    git checkout $FREELAN_BRANCH &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* &&\
    cd /opt/freelan &&\
    scons apps &&\
    scons samples &&\
    # scons install prefix=/opt/ --upnp=yes --install-sandbox=/tlm/freelan
    scons install prefix=/usr/local/ &&\
    cp -r /opt/freelan/build/release/bin /opt/tlm &&\
    ln -s /opt/tlm/freelan /bin/freelan &&\
    rm -rf /opt/freelan &&\
    apt-get autoremove -y --purge $BUILD_DEPENDENCIES &&\
    apt-get autoclean &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Profit !
EXPOSE 12000/udp 12000/tcp

CMD ["/bin/freelan", "-f", "--tap_adapter.enabled=off", "--switch.relay_mode_enabled=yes"]
