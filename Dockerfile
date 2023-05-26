# Base Image
FROM tomcat:9.0.54-jdk8-openjdk-buster

ENV CALAMARI_COMMIT="e766fa6dae35bfda55116aa0b0285156faaf88b8"
ENV KRAKEN_COMMIT="a0c395727c011d3283b34b5f7a9ef6d85970e6d0"
ENV OCROPY_COMMIT="d1472da2dd28373cda4fcbdc84956d13ff75569c"

MAINTAINER Maximilian Nöth

# Enable Networking on port 8080 (Tomcat)
EXPOSE 8080

# Install system dependencies
RUN apt update
RUN apt -y upgrade

RUN apt-get install -y git
RUN apt-get install -y maven
RUN apt-get install -y python-pip
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y python-tk
RUN apt-get install -y wget
RUN apt-get install -y curl
RUN apt-get install -y libblas-dev
RUN apt-get install -y liblapack-dev
RUN apt-get install -y libatlas-base-dev
RUN apt-get install -y gfortran
RUN apt-get install -y pkg-config
RUN apt-get install -y libfreetype6-dev
RUN apt-get install -y libpng-dev
RUN apt-get install -y libjpeg-dev
RUN apt-get install -y zlib1g-dev
RUN apt-get install -y libxml2-dev
RUN apt-get install -y libxslt1-dev

# Update pip
RUN python -m pip install --upgrade pip
RUN python3 -m pip install --upgrade pip


# Download pip for Python 2.7
RUN python -m pip install numpy
RUN python -m pip install scipy==1.2.2
RUN python -m pip install matplotlib==2.0.2
RUN python -m pip install Pillow
RUN python -m pip install lxml

# Install ocropy
WORKDIR /opt
RUN git clone --depth 1 -b master https://gitlab2.informatik.uni-wuerzburg.de/chr58bk/mptv.git ocropy
WORKDIR ocropy
RUN git reset --hard ${OCROPY_COMMIT} && \
    python setup.py install && \
    for OCR_SCRIPT in `cd /usr/local/bin && ls ocropus-*`; \
        do ln -s /usr/local/bin/$OCR_SCRIPT /bin/$OCR_SCRIPT; \
    done

RUN python3 -m pip install --upgrade pip

# Install kraken
WORKDIR /opt
RUN git clone -b main https://github.com/mittagessen/kraken
WORKDIR /opt/kraken
RUN git reset --hard ${KRAKEN_COMMIT} && \
    python3 -m pip install .
RUN rm -r /opt/kraken

# Install calamari
WORKDIR /opt
RUN git clone 1 https://github.com/Calamari-OCR/calamari
WORKDIR /opt/calamari
RUN git reset --hard ${CALAMARI_COMMIT} && \
    python3 -m pip install .
RUN rm -r /opt/calamari

# Downloads calamari models
RUN mkdir -p /var/ocr4all/models/default/default
WORKDIR /var/ocr4all/models/default/default
RUN git clone --depth 1 https://github.com/OCR4all/ocr4all_models
RUN mv ocr4all_models/* .
RUN rm -r ocr4all_models
