# 1) choose base container
# generally use the most recent tag

# base notebook, contains Jupyter and relevant tools
# See https://github.com/ucsd-ets/datahub-docker-stack/wiki/Stable-Tag 
# for a list of the most current containers we maintain
ARG BASE_TAG=latest
FROM  ghcr.io/ucsd-ets/datascience-notebook:2023.4-stable

LABEL maintainer="UC San Diego Research IT Services Ian Kaufman <ikaufman@ucsd.edu>"

# 2) change to root to install packages
USER root

RUN apt-get update && apt-get install -y htop
RUN apt-get install -y tcsh bison bc xorg-dev libz-dev libbz2-dev
#RUN apt-get -y install openmpi-bin libopenmpi-dev

# 3) install packages using notebook user
USER jovyan

# RUN conda install -y scikit-learn

RUN pip install --no-cache-dir networkx scipy

# Override command to disable running jupyter notebook at launch
# CMD ["/bin/bash"]
