# Base Image
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# Enable Networking on port 5000 (Flask), 8080 (Tomcat)
EXPOSE 5000 8080

# Installing dependencies and deleting cache
RUN apt-get update && apt-get install -y \
    locales \
    git \
    maven \
    tomcat8 \
    openjdk-8-jdk-headless \
    python2.7 python-pip python3 python3-pip python3-pil python-tk \
    wget \
    supervisor && \
    pip install scikit-image numpy matplotlib scipy lxml && \
    pip3 install lxml setuptools && \
    rm -rf /var/lib/apt/lists/*

#    python-skimage \
#    python2.7-numpy \
#    python-matplotlib \
#    python2.7-scipy \
#    python2.7-lxml \

#    python3-lxml \
#    python3-setuptools \

# Set the locale, Solve Tomcat issues with Ubuntu

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 CATALINA_HOME=/usr/share/tomcat8

# Install tensorflow
RUN pip3 install --upgrade tensorflow