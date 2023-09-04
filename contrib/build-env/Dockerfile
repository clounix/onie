#  Copyright (C) 2018 Curt Brune <curt@cumulusnetworks.com>
#
#  Modified with permission from Benayak Karki
#
#  SPDX-License-Identifier:     GPL-2.0

FROM debian:9

RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list
RUN echo "deb-src http://archive.debian.org/debian stretch main" >> /etc/apt/sources.list
RUN echo "deb http://archive.debian.org/debian stretch-backports main" >> /etc/apt/sources.list
RUN echo  "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list
RUN echo  "deb-src http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

# Add initial development packages
RUN apt-get update && apt-get install -y \
    build-essential stgit u-boot-tools util-linux \
    gperf device-tree-compiler python-all-dev xorriso \
    autoconf automake bison flex texinfo libtool libtool-bin \
    realpath gawk libncurses5 libncurses5-dev bc \
    dosfstools mtools pkg-config git wget help2man libexpat1 \
    libexpat1-dev fakeroot python-sphinx rst2pdf \
    libefivar-dev libnss3-tools libnss3-dev libpopt-dev \
    libssl-dev sbsigntool uuid-runtime uuid-dev cpio \
    bsdmainutils curl sudo autopoint unzip

CMD ["/bin/bash"]
