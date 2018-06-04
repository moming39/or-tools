FROM ubuntu:16.04

ARG SRC_GIT_BRANCH
ENV SRC_GIT_BRANCH ${SRC_GIT_BRANCH:-master}

RUN apt update \
&& apt install -y -q \
git wget make cmake autoconf libtool zlib1g-dev gawk g++ curl subversion \
swig lsb-release \
python-dev python-wheel python-setuptools python-six \
python3-dev python3-wheel python3-setuptools \
default-jdk \
mono-complete \
&& apt clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /root
RUN git clone -b "$SRC_GIT_BRANCH" --single-branch https://github.com/google/or-tools
WORKDIR /root/or-tools
RUN make third_party
RUN make all -j5
