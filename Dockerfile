# 1) choose base container
# generally use the most recent tag

# base notebook, contains Jupyter and relevant tools
# See https://github.com/ucsd-ets/datahub-docker-stack/wiki/Stable-Tag 
# for a list of the most current containers we maintain
#ARG BASE_TAG=latest
#FROM  ghcr.io/ucsd-ets/datascience-notebook:2023.4-stable
ARG PYTHON_VERSION=python-3.9.5
#FROM jupyter/datascience-notebook:$PYTHON_VERSION
#FROM  ghcr.io/ucsd-ets/scipy-ml-notebook:2023.4-stable
FROM jupyter/base-notebook:$PYTHON_VERSION

LABEL maintainer="UC San Diego Research IT Services Ian Kaufman <ikaufman@ucsd.edu>"

# 2) change to root to install packages
USER root

ARG LIBNVINFER=7.2.2 LIBNVINFER_MAJOR_VERSION=7 CUDA_VERSION=11.8

RUN apt-get update && apt-get install -y htop
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NOWARNINGS="yes"

RUN apt-get update -y && \
    apt-get -qq install -y --no-install-recommends \
    git \
    curl \
    rsync \
    unzip \
    less \
    nano \
    vim \
    cmake \
    tmux \
    screen \
    gnupg \
    htop \
    wget \
    openssh-client \
    openssh-server \
    p7zip \
    apt-utils \
    jq \
    p7zip-full \
    build-essential \
    tcsh bison bc xorg-dev libz-dev libbz2-dev flex openmpi-bin libopenmpi-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    chmod g-s /usr/bin/screen && \
    chmod 1777 /var/run/screen
    #apt-get install -y tcsh bison bc xorg-dev libz-dev libbz2-dev flex openmpi-bin libopenmpi-dev
    #apt-get install -y tcsh bison bc xorg-dev libz-dev libbz2-dev flex openmpi-bin libopenmpi-dev nvidia-cuda-toolkit

######################################
# Now add in CUDA-11.8 tools/libraries
COPY --from=nvcr.io/nvidia/cuda:11.8.0-devel-ubuntu20.04 /usr/local/cuda-11.8 /usr/local/cuda-11.8
RUN ln -s cuda-11.8 /usr/local/cuda && ln -s cuda-11.8 /usr/local/cuda-11

# Configure dynamic library locations (similar to LD_LIBRARY_PATH)
RUN echo '/usr/local/cuda/targets/x86_64-linux/lib' >> /etc/ld.so.conf.d/000_cuda.conf && \
    echo '/usr/local/cuda-11/targets/x86_64-linux/lib' >> /etc/ld.so.conf.d/989_cuda-11.conf && \
    ( echo '/usr/local/nvidia/lib'; echo '/usr/local/nvidia/lib64' ) >> /etc/ld.so.conf.d/nvidia.conf && \
    ldconfig 

ENV CUDA_HOME=/usr/local/cuda
    
    
#RUN apt-get -y install openmpi-bin libopenmpi-dev
#RUN apt-get clean && rm -rf /var/lib/apt/lists/*

 #   USER $NB_UID:$NB_GID
#ENV PATH=${PATH}:/usr/local/nvidia/bin:/opt/conda/bin

#ENV CUDNN_PATH=/opt/conda/lib/python3.9/site-packages/nvidia/cudnn

# starts like this: /opt/conda/pkgs/cudnn-8.6.0.163-pypi_0 8.8.1.3-pypi_0/lib/:/opt/conda/pkgs/cudatoolkit-11.8.0-h37601d7_11/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64
# need to have the end result of running 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/conda/lib/python3.9/site-packages/nvidia/cudnn/lib'
# then the gpu can be detected via CLI.
#ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/conda/lib/python3.9/site-packages/nvidia/cudnn/lib

# Do some CONDA/CUDA stuff
# Copy libdevice file to the required path
#RUN mkdir -p $CONDA_DIR/lib/nvvm/libdevice && \
 # cp $CONDA_DIR/lib/libdevice.10.bc $CONDA_DIR/lib/nvvm/libdevice/

#RUN . /tmp/activate.sh

# Override command to disable running jupyter notebook at launch
# CMD ["/bin/bash"]
