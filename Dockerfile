# Set the base image to Ubuntu 16.04 and NVIDIA GPU
FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

# File Author / Maintainer
MAINTAINER Johannes Debler <johannes.debler@curtin.edu.au>

ARG GUPPY_VERSION=4.4.2
ARG MEGALODON_VERSION=2.2.10
ARG DEBIAN_FRONTEND=noninteractive
ARG CONDA_VERSION=py38_4.9.2
ARG SAMTOOLS_VERSION=1.11
ARG CONDA_MD5=122c8c9beb51e124ab32a0fa6426c656

WORKDIR /home

ENV PATH /opt/conda/bin:$PATH

RUN apt-get update && \
    apt-get install --yes \
                        wget \
                        apt-transport-https \
                        bzip2 \
                        ca-certificates \
                        libglib2.0-0 \
                        libsm6 \
                        libxext6 \
                        libxrender1 \
                        mercurial \
                        subversion \
                        libcurl4-openssl-dev \
                        libssl-dev \
                        libhdf5-cpp-11 \
                        libzmq5 \
                        libboost-atomic1.58.0 \
                        libboost-chrono1.58.0 \
                        libboost-date-time1.58.0 \
                        libboost-filesystem1.58.0 \
                        libboost-program-options1.58.0 \
                        libboost-regex1.58.0 \
                        libboost-system1.58.0 \
                        libboost-log1.58.0 \
                        libboost-iostreams1.58.0 \
                        git &&\

    wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -O miniconda.sh && \
    echo "${CONDA_MD5}  miniconda.sh" > miniconda.md5 && \
    if ! md5sum --status -c miniconda.md5; then exit 1; fi && \
    mkdir -p /opt && \
    sh miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh miniconda.md5 && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy && \

    cd /tmp &&\
    wget -q https://mirror.oxfordnanoportal.com/software/analysis/ont_guppy_${GUPPY_VERSION}-1~xenial_amd64.deb && \
    dpkg -i --ignore-depends=nvidia-384,libcuda1-384 /tmp/ont_guppy_${GUPPY_VERSION}-1~xenial_amd64.deb && \
    rm *.deb && \

    pip3 install numpy cython ont_pyguppy_client_lib  && \

    pip3 install megalodon==${MEGALODON_VERSION} && \
    
    #install samtools so megalodon works with --sort-mappings
    wget https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
    tar -xf samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
    cd samtools-${SAMTOOLS_VERSION} && \
    ./configure --without-curses --disable-bz2 --disable-lzma && \
    make  && \
    make install  && \
    cd ..  && \
    rm samtools-${SAMTOOLS_VERSION} && \
    rm *.bz2 && \

    #git clone https://github.com/nanoporetech/rerio /home/rerio && \
    #/home/rerio/download_model.py /home/rerio/basecall_models/res_dna_r941_min_modbases_5mC_CpG_v001 && \
    #/home/rerio/download_model.py /home/rerio/basecall_models/res_dna_r941_min_modbases_5mC_5hmC_CpG_v001 && \

    mkdir -p /home/ont-guppy/bin && \
    ln -s /usr/bin/guppy_basecall_server /home/ont-guppy/bin/guppy_basecall_server && \

    apt-get autoremove --purge --yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
