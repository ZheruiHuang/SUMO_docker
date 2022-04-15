FROM ubuntu:16.04

LABEL Maintainer="Zherui Huang (huangzherui@sjtu.edu.cn)"
LABEL Description="Dockerised Simulation of Urban MObility(SUMO)"

ENV SUMO_VERSION 1.12.0
ENV SUMO_HOME /root/sumo
# Cmake version must be higher than 3.9 
ENV CMAKE_VERSION 3.23.0
ENV CMAKE_HOME /bin/cmake

# change source
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && \
    sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && \
    apt-get clean && \
    apt-get update

# Install system dependencies
RUN apt-get install -y sudo && \
    sudo apt-get install -y wget \
    python \
    g++ \
    libxerces-c-dev \
    libfox-1.6-dev \
    libgdal-dev \
    libproj-dev \
    libgl2ps-dev \
    swig

# Download and build Cmake
RUN sudo apt-get install -y build-essential libssl-dev && \
    wget https://sourceforge.net/projects/cmake.mirror/files/v$CMAKE_VERSION/cmake-$CMAKE_VERSION.tar.gz && \
    tar -xzf cmake-$CMAKE_VERSION.tar.gz && \
    mv cmake-$CMAKE_VERSION $CMAKE_HOME && \
    rm cmake-$CMAKE_VERSION.tar.gz && \
    cd $CMAKE_HOME && \
    sudo ./bootstrap && sudo make && sudo make install

# Download and build SUMO from source
RUN wget http://downloads.sourceforge.net/project/sumo/sumo/version%20$SUMO_VERSION/sumo-src-$SUMO_VERSION.tar.gz && \
    tar -xzf sumo-src-$SUMO_VERSION.tar.gz && \
    mv sumo-$SUMO_VERSION $SUMO_HOME && \
    rm sumo-src-$SUMO_VERSION.tar.gz && \
    cd $SUMO_HOME && \
    export SUMO_HOME="$PWD" && \
    mkdir build/cmake-build && cd build/cmake-build && \
    cmake ../.. && \
    sudo make -j$(nproc)
    
# Set default docker run command
CMD bash