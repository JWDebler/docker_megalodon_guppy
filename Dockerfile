# Set the base image to Ubuntu 20.04 and NVIDIA GPU
FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04

# File Author / Maintainer
LABEL Maintainer Johannes Debler <johannes.debler@curtin.edu.au>

ARG GUPPY_VERSION=4.4.2
ARG MEGALODON_VERSION=2.2.10

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /home

RUN apt-get update && \
    apt-get install --yes wget \
                        apt-transport-https \
                        libcurl4-openssl-dev \
                        libssl-dev \
                        libhdf5-cpp-100 \
                        libzmq5 \
                        libboost-atomic1.65.1 \
                        libboost-chrono1.65.1 \
                        libboost-date-time1.65.1 \
                        libboost-filesystem1.65.1 \
                        libboost-program-options1.65.1 \
                        libboost-regex1.65.1 \
                        libboost-system1.65.1 \
                        libboost-log1.65.1 \
                        libboost-iostreams1.65.1 \
                        python3 \
                        python3-pip \
                        libnvidia-compute-450-server \
                        git \
                        libz-dev && \
    

    wget -q https://mirror.oxfordnanoportal.com/software/analysis/ont_guppy_4.4.2-1~bionic_amd64.deb && \
    dpkg -i --ignore-depends=nvidia-384,libcuda1-384 ont_guppy_4.4.2-1~bionic_amd64.deb && \
    rm *.deb && \

    pip3 install --upgrade pip && \

    pip3 install numpy cython ont_pyguppy_client_lib  && \

    pip3 install megalodon==2.2.10 && \

    git clone https://github.com/nanoporetech/rerio /home/rerio && \
    /home/rerio/download_model.py /home/rerio/basecall_models/res_dna_r941_min_modbases_5mC_CpG_v001 && \

    mkdir -p /home/ont-guppy/bin && \
    ln -s /usr/bin/guppy_basecall_server /home/ont-guppy/bin/guppy_basecall_server && \

    apt-get autoremove --purge --yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
