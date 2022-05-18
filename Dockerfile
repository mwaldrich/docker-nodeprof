 # NodeProf will be run using Latest Version of Debian
FROM debian:buster-slim

# Update the Ubuntu installation and install build tools for NodeProf
RUN \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential git wget python2.7 nodejs npm libnotify-bin libffi-dev lsb-release procps && \
  wget https://people.debian.org/~paravoid/python-all/unofficial-python-all.asc && \
  mv unofficial-python-all.asc /etc/apt/trusted.gpg.d/ && \
  echo "deb http://people.debian.org/~paravoid/python-all $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/python-all.list && \
  apt-get update && \
  apt-get install -y python3.8

# Install mx and add it to the path
RUN (cd /root; git clone https://github.com/graalvm/mx.git && cd mx && git checkout 99988582643ddd800cd3ef0eb78822f3ae3f603a)
ENV PATH="${PATH}:/root/mx"

# Install the modified JDK and make it available to NodeProf through $JAVA_HOME
RUN (cd /root; \
     wget --quiet https://github.com/graalvm/openjdk8-jvmci-builder/releases/download/jvmci-0.46/openjdk-8u172-jvmci-0.46-linux-amd64.tar.gz; \
     tar xvf openjdk-8u172-jvmci-0.46-linux-amd64.tar.gz)
ENV JAVA_HOME="/root/openjdk1.8.0_172-jvmci-0.46"

ARG nodeprof_repo=docker/nodeprof-clones/public/nodeprof.js

# Install NodeProf
COPY ${nodeprof_repo} /root/nodeprof
RUN (cd /root/nodeprof && \
     (mx sforceimports && mx build && mx test-all))
# we run tests here because some dependencies don't download until
# analyses are actually run.

# Display color output in terminal
ENV TERM xterm-256color

# This container can now be used like `mx`.
# ENTRYPOINT ["/root/mx/mx"]
