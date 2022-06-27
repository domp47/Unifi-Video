FROM ubuntu:20.04

# RUN echo "Updating OS..."
RUN apt-get update > /dev/null
RUN apt-get dist-upgrade -y > /dev/null
RUN apt-get install -y curl > /dev/null

RUN echo "Installing Java 8 Build 8u275..."
RUN curl -sqo /tmp/openjdk-8-jre-headless_8u275-b01.deb "https://launchpadlibrarian.net/505954411/openjdk-8-jre-headless_8u275-b01-0ubuntu1~18.04_amd64.deb" \
    && apt-get install -y /tmp/openjdk-8-jre-headless_8u275-b01.deb > /dev/null \
    && rm /tmp/openjdk-8-jre-headless_8u275-b01.deb

RUN echo "Installing Unifi Video..."
RUN curl -sqo /tmp/unifi-video_3.10.13.deb "https://dl.ubnt.com/firmwares/ufv/v3.10.13/unifi-video.Ubuntu18.04_amd64.v3.10.13.deb" \
    && apt-get install -y /tmp/unifi-video_3.10.13.deb > /dev/null \
    && rm /tmp/unifi-video_3.10.13.deb


# Database Files
VOLUME [ "/data" ]
# Recordings Directory
VOLUME [ "/var/lib/unifi-video/videos" ]


COPY unifi-video /usr/sbin/unifi-video
RUN chmod 500 /usr/sbin/unifi-video

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]