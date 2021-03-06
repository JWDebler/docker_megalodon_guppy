# Set the base image to Ubuntu 20.04 and NVIDIA GPU
FROM nvidia/cuda:11.2.1-base-ubuntu20.04

# File Author / Maintainer
LABEL Maintainer Johannes Debler <johannes.debler@curtin.edu.au>

ARG PACKAGE_VERSION=4.4.2
ARG BUILD_PACKAGES="wget apt-transport-https"
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /home

RUN apt-get update && \
    apt-get install --yes $BUILD_PACKAGES \
                        libcurl4-openssl-dev \
                        libssl-dev \
                        libhdf5-cpp-103 \
                        libzmq5 \
                        libboost-atomic1.71.0 \
                        libboost-chrono1.71.0 \
                        libboost-date-time1.71.0 \
                        libboost-filesystem1.71.0 \
                        libboost-program-options1.71.0 \
                        libboost-regex1.71.0 \
                        libboost-system1.71.0 \
                        libboost-log1.71.0 \
                        libboost-iostreams1.71.0 \
                        python3 \
                        python3-pip \
                        wget \
                        libnvidia-compute-460-server \
                        git
    

RUN wget -q https://mirror.oxfordnanoportal.com/software/analysis/ont_guppy_${PACKAGE_VERSION}-1~focal_amd64.deb && \
    dpkg -i --ignore-depends=nvidia-384,libcuda1-384 ont_guppy_${PACKAGE_VERSION}-1~focal_amd64.deb && \
    rm *.deb

RUN pip3 install numpy cython ont_pyguppy_client_lib 

RUN pip3 install megalodon

RUN git clone https://github.com/nanoporetech/rerio /home/rerio && \
    /home/rerio/download_model.py rerio/basecall_models/res_dna_r941_min_modbases_5mC_CpG_v001

RUN mkdir -p ont-guppy/bin && \
    ln -s /usr/bin/guppy_basecall_server /home/ont-guppy/bin/guppy_basecall_server

RUN apt-get autoremove --purge --yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
