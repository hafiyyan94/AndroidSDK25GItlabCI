FROM ubuntu:16.04
MAINTAINER Hafiyyan <hafiyyan94@gmail.com>

ENV VERSION_SDK_TOOLS "26.0.1"
ENV VERSION_BUILD_TOOLS "25.0.3"
ENV VERSION_TARGET_SDK "25"

ENV SDK_PACKAGES "build-tools-${VERSION_BUILD_TOOLS},android-${VERSION_TARGET_SDK},addon-google_apis-google-${VERSION_TARGET_SDK},platform-tools,extra-android-m2repository,extra-android-support,extra-google-google_play_services,extra-google-m2repository,sys-img-x86-android-${VERSION_TARGET_SDK},sys-img-x86-google_apis-${VERSION_TARGET_SDK}"

ENV ANDROID_HOME "/sdk"
ENV PATH "$PATH:${ANDROID_HOME}/tools"
ENV DEBIAN_FRONTEND noninteractive

# Accept License

# Constraint Layout / [Solver for ConstraintLayout 1.0.0-alpha8, ConstraintLayout for Android 1.0.0-alpha8]
RUN mkdir -p $ANDROID_HOME/licenses/
RUN echo "8933bad161af4178b1185d1a37fbf41ea5269c55" > $ANDROID_HOME/licenses/android-sdk-license
RUN apt-get -y update && apt-get -y upgrade && apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
      curl \
      html2text \
      openjdk-8-jdk \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses5 \
      lib32z1 \
      unzip \
      qtbase5-dev \
      qtdeclarative5-dev \
      wget \
      qemu-kvm \
      build-essential \
      python2.7 libvirt-bin ubuntu-vm-builder bridge-utils \
      python2.7-dev \
      yamdi \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

ENV ANDROID_SDK_TOOLS "3859397"

RUN wget -nv http://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip && unzip sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip -d /sdk && \
    rm -v sdk-tools-linux-${ANDROID_SDK_TOOLS}.zip

RUN mkdir /sdk/tools/keymaps && \
    touch /sdk/tools/keymaps/en-us

RUN mkdir /helpers

COPY wait-for-avd-boot.sh /helpers

RUN mkdir /.android && echo 'count=0' > /.android/repositories.cfg # Avoid warning
RUN echo y | ${ANDROID_HOME}/tools/bin/sdkmanager --update
RUN (while [ 1 ]; do sleep 5; echo y; done) | ${ANDROID_HOME}/tools/bin/sdkmanager "tools" "platform-tools" "build-tools;"$VERSION_BUILD_TOOLS "platforms;android-"$VERSION_TARGET_SDK "extras;android;m2repository" "extras;google;google_play_services" "extras;google;m2repository"

RUN apt-get -y install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils

#Creating and Running Emulator
RUN echo y | ${ANDROID_HOME}/tools/bin/sdkmanager "system-images;android-24;default;armeabi-v7a"
RUN echo no | $ANDROID_HOME/tools/bin/avdmanager create avd -n test -k "system-images;android-24;default;armeabi-v7a"
