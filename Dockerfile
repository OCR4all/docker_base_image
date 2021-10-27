# Base Image
FROM tomcat:9.0-jdk8-temurin-focal

ENV CALAMARI_VERSION=2.1.2
ENV KRAKEN_VERSION=3.0.4
ENV OCROPY_COMMIT="d1472da2dd28373cda4fcbdc84956d13ff75569c"
ENV HELPER_SCRIPTS_COMMIT="0cb915e20194d19a1c8a6023565ef3e8e0a54c87"

MAINTAINER Maximilian Nöth

# Enable Networking on port 8080 (Tomcat)
EXPOSE 8080

RUN apt update && \
    apt -y install software-properties-common && \
    add-apt-repository -y ppa:deadsnakes/ppa

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    git \
    maven \
    python3.8 \
    python3-pip \
    python2-minimal \
    python-tk \
    wget \
    curl

RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
RUN python2 get-pip.py
RUN python2 -m pip install numpy scipy matplotlib Pillow lxml

# Install OCR4all-helper-scripts
# Install helper scripts to make all scripts available to JAVA environment
WORKDIR /opt
RUN git clone -b master https://github.com/OCR4all/OCR4all_helper-scripts.git
WORKDIR /opt/OCR4all_helper-scripts
RUN git reset --hard ${HELPER_SCRIPTS_COMMIT} && \
    python3 -m pip install .

# Install ocropy
RUN cd /opt && git clone -b master https://gitlab2.informatik.uni-wuerzburg.de/chr58bk/mptv.git ocropy && \
    cd ocropy && git reset --hard ${OCROPY_COMMIT} && \
    python2 setup.py install && \
    for OCR_SCRIPT in `cd /usr/local/bin && ls ocropus-*`; \
        do ln -s /usr/local/bin/$OCR_SCRIPT /bin/$OCR_SCRIPT; \
    done


# Install python dependencies
RUN python3.8 -m pip install --upgrade pip

RUN python3.8 -m pip install --no-cache-dir calamari-ocr==$CALAMARI_VERSION
RUN python3.8 -m pip install --no-cache-dir kraken==$KRAKEN_VERSION
