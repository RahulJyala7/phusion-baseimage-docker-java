oc	# Use phusion/baseimage as base image. To make your builds
# reproducible, make sure you lock down to a specific version, not
# to `latest`! See
# https://github.com/phusion/baseimage-docker/blob/master/Changelog.md
# for a list of version numbers.
FROM phusion/baseimage:0.11

MAINTAINER  Author Name Rahul Jyala

RUN echo "deb http://archive.ubuntu.com/ubuntu bionic main universe" > /etc/apt/sources.list

RUN apt-get -y update

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q software-properties-common

ENV JAVA_VER 8
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

RUN apt-get install -y sudo

RUN echo 'deb http://ppa.launchpad.net/webupd8team/java/ubuntu bionic main' >> /etc/apt/sources.list && \
    echo 'deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu bionic main' >> /etc/apt/sources.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C2518248EEA14886 && \
    apt-get update && \
    echo oracle-java${JAVA_VER}-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections && \
    apt-get install -y --force-yes --no-install-recommends oracle-java${JAVA_VER}-installer oracle-java${JAVA_VER}-set-default && \
    apt-get clean && \
    rm -rf /var/cache/oracle-jdk${JAVA_VER}-installer

RUN update-java-alternatives -s java-8-oracle

RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> ~/.bashrc

CMD ["/sbin/my_init"]

ENV PORT=50052
ENV MASTER_API=192.168.0.171:30155

RUN useradd -r datanext

RUN echo $PORT > /etc/container_environment/PORT
RUN echo $MASTER_API > /etc/container_environment/MASTER_API

RUN mkdir /var/datanext

COPY ./target/engine-bundled.jar /var/datanext/engine-bundled.jar

RUN chown datanext:datanext /var/datanext/engine-bundled.jar

RUN mkdir /etc/service/dataflowservice
RUN chmod +x /var/datanext/engine-bundled.jar

COPY dataflowservice.sh /etc/service/dataflowservice/run
RUN sed -i -e 's/\r$//' /etc/service/dataflowservice/run
RUN chmod +x /etc/service/dataflowservice/run

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
