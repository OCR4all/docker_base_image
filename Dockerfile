# Base Image
FROM nvidia/cuda:11.2.2-runtime-ubuntu20.04

ENV CALAMARI_COMMIT="2f71b7eb08339d25ccb21d80c1d5b851f3d5bdaa"
ENV KRAKEN_COMMIT="95981e0bcd354f37e2df7d3d07d40ebefc426400"
ENV OCROPY_COMMIT="d1472da2dd28373cda4fcbdc84956d13ff75569c"

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV TOMCAT_VERSION 9.0.85

MAINTAINER Maximilian Nöth

# Enable Networking on port 8080 (Tomcat)
EXPOSE 8080


ENV DEBIAN_FRONTEND=noninteractive
# Install system dependencies
RUN apt update

RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get install -y build-essential
RUN apt-get install -y python2
RUN apt-get install -y python3-pip python3-setuptools python3-wheel python3.7-distutils python3.7
RUN apt-get install -y python-tk
RUN apt-get install -y openjdk-8-jdk-headless
RUN apt-get install -y git
RUN apt-get install -y maven
RUN apt-get install -y wget
RUN apt-get install -y curl
RUN apt-get clean

# Update pip
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
RUN python2 get-pip.py
RUN python2 -m pip install --upgrade pip
RUN python3.7 -m pip install --upgrade pip
RUN python3 -m pip install --upgrade pip

# Download pip for Python 2.7
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
RUN python2 get-pip.py
RUN python2 -m pip install numpy scipy matplotlib==2.0.2 Pillow lxml

# Install ocropy
WORKDIR /opt
RUN git clone --depth 1 -b master https://gitlab2.informatik.uni-wuerzburg.de/chr58bk/mptv.git ocropy
WORKDIR ocropy
RUN git reset --hard ${OCROPY_COMMIT} && \
    python2 setup.py install && \
    for OCR_SCRIPT in `cd /usr/local/bin && ls ocropus-*`; \
        do ln -s /usr/local/bin/$OCR_SCRIPT /bin/$OCR_SCRIPT; \
    done

# Install kraken
WORKDIR /opt
RUN git clone --depth 1 -b main https://github.com/mittagessen/kraken
WORKDIR /opt/kraken
RUN git reset --hard ${KRAKEN_COMMIT} && \
    python3 -m pip install .
RUN rm -r /opt/kraken

# Install calamari
WORKDIR /opt
RUN git clone --depth 1 https://github.com/Calamari-OCR/calamari
WORKDIR /opt/calamari
RUN git reset --hard ${CALAMARI_COMMIT} && \
    python3.7 -m pip install .
RUN rm -r /opt/calamari

# Downloads calamari models
RUN mkdir -p /var/ocr4all/models/default/default
WORKDIR /var/ocr4all/models/default/default
RUN git clone --depth 1 https://github.com/OCR4all/ocr4all_models
RUN mv ocr4all_models/* .
RUN rm -r ocr4all_models

# Install Tomcat9
RUN mkdir $CATALINA_HOME
RUN wget https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/tomcat.tar.gz
RUN cd /tmp && tar xvfz tomcat.tar.gz
RUN cp -Rv /tmp/apache-tomcat-${TOMCAT_VERSION}/* $CATALINA_HOME
RUN rm -rf /tmp/apache-tomcat-${TOMCAT_VERSION}
RUN rm -rf /tmp/tomcat.tar.gz