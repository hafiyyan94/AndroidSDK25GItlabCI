# Pull base image.
FROM openjdk:8-jdk
# original maintainer: navarroaxel <navarroaxel@gmail.com>
MAINTAINER hafiyyan94 <hafiyyan94@gmail.com>

# Creating Variable for Android Package
ENV ANDROID_COMPILE_SDK "25"
ENV ANDROID_BUILD_TOOLS "25.0.3"
ENV ANDROID_SDK_TOOLS "3859397"  # "26.0.1"
ENV ANDROID_CMAKE_REV "3.6.3155560"
ENV GIT_SUBMODULE_STRATEGY recursive # Remove if you don't have to clone submodules
ENV SDK_HOME /usr/local

#Gradle Installation
ENV GRADLE_VERSION 3.3
ENV GRADLE_SDK_URL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
RUN curl -sSL "${GRADLE_SDK_URL}" -o gradle-${GRADLE_VERSION}-bin.zip  \
	&& unzip gradle-${GRADLE_VERSION}-bin.zip -d ${SDK_HOME}  \
	&& rm -rf gradle-${GRADLE_VERSION}-bin.zip
ENV GRADLE_HOME ${SDK_HOME}/gradle-${GRADLE_VERSION}
ENV PATH ${GRADLE_HOME}/bin:$PATH


#Installing Android Dependencies
RUN mkdir $HOME/.android # For sdkmanager configs
RUN echo 'count=0' > $HOME/.android/repositories.cfg # Avoid warning
RUN wget --output-document=android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip
RUN mkdir $SDK_HOME/android-sdk-linux
RUN unzip -qq android-sdk.zip -d $SDK_HOME/android-sdk-linux
ENV ANDROID_HOME $SDK_HOME/android-sdk-linux
RUN export PATH=$PATH:$ANDROID_HOME/platform-tools/:$ANDROID_NDK_HOME
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager --update 
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'tools'
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'platform-tools'
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'build-tools;'$ANDROID_BUILD_TOOLS
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'platforms;android-'$ANDROID_COMPILE_SDK
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'extras;android;m2repository'
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'extras;google;google_play_services'
RUN echo y | $ANDROID_HOME/tools/bin/sdkmanager 'extras;google;m2repository'

#Installing Android CMake
RUN wget -q https://dl.google.com/android/repository/cmake-$ANDROID_CMAKE_REV-linux-x86_64.zip -O android-cmake.zip
RUN unzip -q android-cmake.zip -d ${ANDROID_HOME}/cmake
ENV PATH ${PATH}:${ANDROID_HOME}/cmake/bin
RUN chmod u+x ${ANDROID_HOME}/cmake/bin/ -R
