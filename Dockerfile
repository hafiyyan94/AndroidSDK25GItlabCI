# Pull base image.
FROM ubuntu:16.04
# original maintainer: navarroaxel <navarroaxel@gmail.com>
MAINTAINER hafiyyan94 <hafiyyan94@gmail.com>

# Repo for Yarn
RUN apt-key adv --fetch-keys http://dl.yarnpkg.com/debian/pubkey.gpg
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install base software packages
RUN apt-get update && \
    apt-get install -y software-properties-common \
    python-software-properties \
    wget \
    curl \
    git \
    python \
    python-pip \
	python-dev \
	build-essential \
    unzip -y \
    yarn && \
    apt-get clean

# ——————————
# Install Java.
# ——————————

RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

ENV ANDROID_COMPILE_SDK "25"
ENV ANDROID_BUILD_TOOLS "25.0.3"
ENV ANDROID_SDK_TOOLS_REV "3859397"  # "26.0.1"
ENV ANDROID_CMAKE_REV "3.6.3155560"
ENV GIT_SUBMODULE_STRATEGY recursive # Remove if you don't have to clone submodules

#SDK Manager Configs
mkdir $HOME/.android

#Avoid Warning
RUN echo 'count=0' > $HOME/.android/repositories.cfg

#Installing Dependencies
RUN wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS_REV}.zip
RUN mkdir $PWD/android-sdk-linux
RUN unzip -qq android-sdk.zip -d $PWD/android-sdk-linux
RUN export ANDROID_HOME=$PWD/android-sdk-linux
RUN export PATH=$PATH:$ANDROID_HOME/platform-tools/:$ANDROID_NDK_HOME
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager --update 
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'tools'
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'platform-tools'
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'build-tools;'$ANDROID_BUILD_TOOLS
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'platforms;android-'$ANDROID_COMPILE_SDK
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'extras;android;m2repository'
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'extras;google;google_play_services'
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'extras;google;m2repository'
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'cmake;'$ANDROID_CMAKE_REV

