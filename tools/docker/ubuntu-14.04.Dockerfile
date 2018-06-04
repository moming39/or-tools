FROM ubuntu:14.04

ARG SRC_GIT_BRANCH
ENV SRC_GIT_BRANCH ${SRC_GIT_BRANCH:-master}

# note: package "apt-transport-https" is needed by deb command see below
RUN apt-get update \
&& apt-get install -qq \
git wget make cmake3 autoconf libtool zlib1g-dev gawk g++ curl subversion lsb-release libpcre3-dev \
python-dev python-wheel python-setuptools python-six \
python3-dev python3-wheel python3-setuptools \
default-jdk \
apt-transport-https \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Mono install
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
&& echo "deb https://download.mono-project.com/repo/ubuntu stable-trusty main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list \
&& apt-get update \
&& apt-get install -qq mono-complete \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Swig install
RUN wget "https://downloads.sourceforge.net/project/swig/swig/swig-3.0.12/swig-3.0.12.tar.gz" \
&& tar xvf swig-3.0.12.tar.gz && rm swig-3.0.12.tar.gz \
&& cd swig-3.0.12 && ./configure --prefix=/usr && make -j 4 && make install \
&& cd .. && rm -rf swig-3.0.12

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /root
RUN git clone -b "$SRC_GIT_BRANCH" --single-branch https://github.com/google/or-tools
WORKDIR /root/or-tools
RUN make third_party
RUN make all -j5
