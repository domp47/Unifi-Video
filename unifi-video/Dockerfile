FROM ubuntu:20.04

# RUN echo "Updating OS..."
RUN apt update > /dev/null
RUN apt dist-upgrade > /dev/null

RUN echo "Installing Java 8 Build 8u275..."
RUN curl -qo /tmp/openjdk-8-jre-headless_8u275-b01.deb "https://launchpadlibrarian.net/505954411/openjdk-8-jre-headless_8u275-b01-0ubuntu1~18.04_amd64.deb" \
    && sudo dpkg -i /tmp/openjdk-8-jre-headless_8u275-b01.deb > /dev/null\
    && rm /tmp/openjdk-8-jre-headless_8u275-b01.deb

RUN echo "Installing JSVC..."
RUN apt install jsvc

RUN echo "Installing MongoDB..."
