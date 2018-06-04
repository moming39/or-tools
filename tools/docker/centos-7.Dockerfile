FROM centos:7

ARG SRC_GIT_BRANCH
ENV SRC_GIT_BRANCH ${SRC_GIT_BRANCH:-master}

RUN yum -y update \
&& yum -y install yum-utils \
&& rpm --import "http://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF" \
&& yum-config-manager --add-repo http://download.mono-project.com/repo/centos7/ \
&& yum -y install \
wget git make autoconf libtool zlib-devel gawk gcc-c++ curl subversion \
redhat-lsb-core pcre-devel which \
python-devel python-setuptools python-six python-wheel \
java-1.8.0-openjdk  java-1.8.0-openjdk-devel \
mono-devel \
&& yum clean all \
&& rm -rf /var/cache/yum

# Install CMake
RUN wget "https://cmake.org/files/v3.8/cmake-3.8.2-Linux-x86_64.sh" && \
    chmod 775 cmake-3.8.2-Linux-x86_64.sh && \
    yes | ./cmake-3.8.2-Linux-x86_64.sh --prefix=/usr --exclude-subdir

# Install Swig
RUN wget "https://downloads.sourceforge.net/project/swig/swig/swig-3.0.12/swig-3.0.12.tar.gz" && \
    tar xvf swig-3.0.12.tar.gz && rm swig-3.0.12.tar.gz && \
    cd swig-3.0.12 && ./configure --prefix=/usr && \
    make -j 4 && make install && cd .. && rm -rf swig-3.0.12

ENV TZ=America/Los_Angeles
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /root
RUN git clone -b "$SRC_GIT_BRANCH" --single-branch https://github.com/google/or-tools
WORKDIR /root/or-tools
RUN make third_party
RUN make all -j5
