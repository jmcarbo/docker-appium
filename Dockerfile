FROM ubuntu:14.04
MAINTAINER Alejandro Gomez <agommor@gmail.com>

#================================
# Build arguments
#================================

ARG ANDROID_SDK_VERSION=23
ARG JAVA_VERSION=8
ARG APPIUM_VERSION=1.5.2
ARG ANDROID_HOME=/opt/android-sdk-linux
ARG APPIUM_HOME=/opt/appium


#================================
# Env variables
#================================

ENV DEBIAN_FRONTEND noninteractive
ENV ANDROID_SDK_VERSION ${ANDROID_SDK_VERSION}
ENV ANDROID_SDKTOOLS_VERSION 24.4.1
ENV JAVA_VERSION ${JAVA_VERSION}
ENV APPIUM_VERSION ${APPIUM_VERSION}
ENV ANDROID_HOME ${ANDROID_HOME}
ENV APPIUM_HOME ${APPIUM_HOME}
ENV SDK_PACKAGES \
tools,\
platform-tools,\
build-tools-23.0.3,\
build-tools-23.0.2,\
build-tools-23.0.1,\
build-tools-22.0.1,\
android-23,\
android-22,\
sys-img-armeabi-v7a-android-$ANDROID_SDK_VERSION,\
sys-img-x86_64-android-$ANDROID_SDK_VERSION,\
sys-img-x86-android-$ANDROID_SDK_VERSION,\
sys-img-armeabi-v7a-google_apis-$ANDROID_SDK_VERSION,\
sys-img-x86_64-google_apis-$ANDROID_SDK_VERSION,\
sys-img-x86-google_apis-$ANDROID_SDK_VERSION,\
addon-google_apis-google-$ANDROID_SDK_VERSION,\
source-$ANDROID_SDK_VERSION,extra-android-m2repository,\
extra-android-support,\
extra-google-google_play_services,\
extra-google-m2repository


#================================
# Install Android SDK's and Platform tools
#================================

ADD assets/etc/apt/apt.conf.d/99norecommends /etc/apt/apt.conf.d/99norecommends
ADD assets/etc/apt/sources.list /etc/apt/sources.list

RUN dpkg --add-architecture i386 \
  && apt-get update -y \
  && apt-get install -y software-properties-common python-software-properties \
  && add-apt-repository ppa:webupd8team/java \
  && apt-get update -y \
  && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections \
  && apt-get -y --no-install-recommends install \
    xvfb \
    x11vnc \
    libc6-i386 \
    lib32stdc++6 \
    lib32gcc1 \
    lib32ncurses5 \
    lib32z1 \
    wget \
    curl \
    unzip \
    oracle-java${JAVA_VERSION}-installer \
  && wget --progress=dot:giga -O /opt/android-sdk-linux.tgz \
    https://dl.google.com/android/android-sdk_r$ANDROID_SDKTOOLS_VERSION-linux.tgz \
  && tar xzf /opt/android-sdk-linux.tgz -C /tmp \
  && rm /opt/android-sdk-linux.tgz \
  && mv /tmp/android-sdk-linux $ANDROID_HOME \
  && echo y | $ANDROID_HOME/tools/android update sdk -s -u -a -t ${SDK_PACKAGES} \
  && apt-get -qqy clean \
  && rm -rf /var/cache/apt/*

ENV PATH $PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools

#================================
# X11 Configuration
#================================

ENV X11_RESOLUTION "1280x1024x24"
ENV DISPLAY :1
ENV VNC_PASSWD "changeme"

#==========================
# Install Appium Dependencies
#==========================

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash - \
  && apt-get -qqy install \
    nodejs \
    python \
    make \
    build-essential \
    g++

#=====================
# Install Appium
#=====================

RUN mkdir $APPIUM_HOME \
  && cd $APPIUM_HOME \
  && npm install appium@$APPIUM_VERSION \
  && ln -s $APPIUM_HOME/node_modules/.bin/appium /usr/bin/appium

EXPOSE 4723

#==========================
# Run appium as default
#==========================
CMD /usr/bin/appium

COPY ./assets/bin/entrypoint /
ENTRYPOINT ["/entrypoint"]