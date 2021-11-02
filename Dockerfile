# Base Image
FROM tomcat:9.0-jdk8-temurin-focal

ENV CALAMARI_VERSION=2.1.4
ENV KRAKEN_COMMIT="5a7e99a92ef7107f2c60c1b30ecf9965893d173d"
ENV OCROPY_COMMIT="d1472da2dd28373cda4fcbdc84956d13ff75569c"
ENV HELPER_SCRIPTS_COMMIT="e54a5250246fad32d9bc308437ea5ed6e19bac79"

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
# Downloads models
RUN mkdir -p /var/ocr4al/models/default/default
WORKDIR /var/ocr4all/models/default/default
RUN wget https://github.com/Calamari-OCR/calamari_models/archive/refs/tags/2.0.tar.gz
RUN tar -xvzf /var/ocr4all/models/default/default/2.0.tar.gz --strip-components=1
RUN rm -r /var/ocr4all/models/default/default/2.0.tar.gz

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
RUN rm -r /opt/OCR4all_helper-scripts

# Install ocropy
WORKDIR /opt
RUN git clone -b master https://gitlab2.informatik.uni-wuerzburg.de/chr58bk/mptv.git ocropy
WORKDIR ocropy
RUN git reset --hard ${OCROPY_COMMIT} && \
    python2 setup.py install && \
    for OCR_SCRIPT in `cd /usr/local/bin && ls ocropus-*`; \
        do ln -s /usr/local/bin/$OCR_SCRIPT /bin/$OCR_SCRIPT; \
    done

RUN python3.8 -m pip install --upgrade pip

WORKDIR /opt
RUN git clone -b master https://github.com/mittagessen/kraken
WORKDIR /opt/kraken
RUN git reset --hard ${KRAKEN_COMMIT} && \
    python3 -m pip install .
RUN rm -r /opt/kraken

RUN python3.8 -m pip install --no-cache-dir calamari-ocr==$CALAMARI_VERSION
