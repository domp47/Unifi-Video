FROM ubuntu:20.04

# Set correct environment variables
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV PUID="99" PGID="100" UMASK="002"

COPY unifi-video.patch /unifi-video.patch
COPY run.sh /run.sh

RUN apt-get update > /dev/null
RUN apt-get dist-upgrade -y > /dev/null
RUN apt-get install -y wget > /dev/null
RUN wget -q -O /tmp/java.deb "https://launchpadlibrarian.net/505954411/openjdk-8-jre-headless_8u275-b01-0ubuntu1~18.04_amd64.deb" && \
    apt-get install -y \
    /tmp/java.deb \
    moreutils \
    patch \
    > /dev/null && \
    rm /tmp/java.deb

RUN wget -q -O /tmp/unifi-video.deb "https://dl.ubnt.com/firmwares/ufv/v3.10.13/unifi-video.Ubuntu18.04_amd64.v3.10.13.deb" && \
    apt-get install -y /tmp/unifi-video.deb > /dev/null && \
    patch -lN /usr/sbin/unifi-video /unifi-video.patch && \
    rm /tmp/unifi-video.deb && \
    rm /unifi-video.patch && \
    chmod 755 /run.sh

# Patch log4j vuln
RUN wget -q -O apache-log4j-2.17.2-bin.tar.gz https://dlcdn.apache.org/logging/log4j/2.17.2/apache-log4j-2.17.2-bin.tar.gz && \
  tar -zxf apache-log4j-2.17.2-bin.tar.gz apache-log4j-2.17.2-bin/log4j-api-2.17.2.jar apache-log4j-2.17.2-bin/log4j-core-2.17.2.jar apache-log4j-2.17.2-bin/log4j-slf4j-impl-2.17.2.jar && \
  install --backup -m 400 -o 1003 -g 104 -T apache-log4j-2.17.2-bin/log4j-api-2.17.2.jar /usr/lib/unifi-video/lib/log4j-api-2.1.jar && \
  install --backup -m 400 -o 1003 -g 104 -T apache-log4j-2.17.2-bin/log4j-core-2.17.2.jar /usr/lib/unifi-video/lib/log4j-core-2.1.jar && \
  install --backup -m 400 -o 1003 -g 104 -T apache-log4j-2.17.2-bin/log4j-slf4j-impl-2.17.2.jar /usr/lib/unifi-video/lib/log4j-slf4j-impl-2.1.jar && \
  rm -fr /apache-log4j-2.17.2-bin.tar.gz /apache-log4j-2.17.2-bin

RUN mkdir -p /data/db

# RTMP, RTMPS & RTSP, Inbound Camera Streams & Camera Management (NVR Side), UVC-Micro Talkback (Camera Side)
# HTTP & HTTPS Web UI + API, Video over HTTP & HTTPS
EXPOSE 1935/tcp 7444/tcp 7447/tcp 6666/tcp 7442/tcp 7004/udp 7080/tcp 7443/tcp 7445/tcp 7446/tcp

ENTRYPOINT [ "/run.sh" ]