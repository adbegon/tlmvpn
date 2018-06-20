FROM debian:stretch-slim

# Update package list
RUN apt-get update && apt-get -y upgrade &&\
    mkdir /etc/freelan &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*


ENV DEPENDENCIES libssl1.1 libboost-system1.62.0 libboost-thread1.62.0 libboost-filesystem1.62.0 libboost-date-time1.62.0 libboost-program-options1.62.0 libboost-iostreams1.62.0 libcurl4-openssl-dev libminiupnpc10 libcurl3
ENV BUILD_DEPENDENCIES scons python libssl-dev libcurl4-openssl-dev libboost-system-dev libboost-thread-dev libboost-program-options-dev libboost-filesystem-dev libboost-iostreams-dev libminiupnpc-dev build-essential git 
ENV FREELAN_BRANCH=master CXX=g++
WORKDIR /opt/
    # Install dependencies
ADD ./files/freelan.cfg /etc/freelan/    
RUN apt-get update && apt-get install -y $DEPENDENCIES && apt-get install -y $BUILD_DEPENDENCIES &&\
    # Get FreeLAN sources
    git clone https://github.com/freelan-developers/freelan.git /opt/freelan &&\
    cd /opt/freelan &&\ 
    git checkout $FREELAN_BRANCH &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* &&\
    cd /opt/freelan &&\
    # Compile FreeLAN
    scons apps &&\
    scons samples &&\
    scons install prefix=/usr/local/ &&\
    cp -r /opt/freelan/build/release/bin /opt/tlm &&\
    ln -s /opt/tlm/freelan /bin/freelan &&\
    rm -rf /opt/freelan &&\
    # Remove sources and dependencies
    apt-get autoremove -y --purge $BUILD_DEPENDENCIES &&\
    apt-get autoremove && apt-get autoclean &&\
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# Profit !!
EXPOSE 12000/udp 12000/tcp

CMD ["/bin/freelan", "-f", "--tap_adapter.enabled=off", "--switch.relay_mode_enabled=yes",  "-c=/etc/freelan/freelan.cfg"]
