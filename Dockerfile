# Base Image
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

# Enable Networking on port 8080 (Tomcat)
EXPOSE 8080

# Copy files containing the necessary python dependencies
COPY requirements_py2.txt requirements_py3.txt /tmp/

# Installing dependencies and deleting cache
RUN apt-get update && apt-get install -y \
    locales \
    git \
    maven \
    tomcat8 \
    openjdk-8-jdk-headless \
    python python-pip python3 python3-pip python3-pil python-tk \
    wget \
    supervisor && \
    rm -rf /var/lib/apt/lists/*

# Installing python dependencies
RUN python -m pip install --upgrade pip && \
    python -m pip install --upgrade -r /tmp/requirements_py2.txt && \
    python3 -m pip install --upgrade pip && \
    python3 -m pip install --upgrade -r /tmp/requirements_py3.txt && \
    rm /tmp/requirements_py2.txt /tmp/requirements_py3.txt

# Set the locale, Solve Tomcat issues with Ubuntu
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8 CATALINA_HOME=/usr/share/tomcat8

# Install tensorflow
RUN pip3 install --upgrade tensorflow