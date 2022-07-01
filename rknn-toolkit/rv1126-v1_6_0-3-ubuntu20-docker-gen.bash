#!/bin/bash
# docker-gen.bash

# special suffix ux=... for user name and directories
#   e.g. "ux=ua1" will create:
#          rv1126ua1    --docker guest user name
#          rvimgua1     --docker image name
#          rvbua1       --docker container name
ux="ub7"


echo Creating bb.dockerfile ...

# create bb.dockerfile:
cat << EOF1 > bb.dockerfile

 FROM ubuntu:bionic-20220531

 RUN apt-get update
 RUN apt-get install -y git tree openssh-client make
 RUN apt-get install -y bzip2 gcc libncurses5-dev bc
 RUN apt-get install -y file vim
 RUN apt-get install -y zlib1g-dev g++
 RUN apt-get install -y libssl-dev

 # tzdata
   ## preesed tzdata, update package index, upgrade packages and install needed software
   RUN truncate -s0 /tmp/preseed.cfg && \
       (echo "tzdata tzdata/Areas select America" >> /tmp/preseed.cfg) && \
       (echo "tzdata tzdata/Zones/America select Los_Angeles" >> /tmp/preseed.cfg) && \
       debconf-set-selections /tmp/preseed.cfg && \
       rm -f /etc/timezone /etc/localtime && \
       apt-get update && \
       DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
       apt-get install -y tzdata
   ## cleanup of files from setup
   RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

 # from "Description of the installation"
 RUN apt-get update
 RUN apt-get install -y texinfo texlive gawk 

 # needed by wl18xx build
 RUN apt-get install -y autoconf libtool libglib2.0-dev bison flex

 # rk1808 96boards-tb-96aiot dependencies:
 #RUN dpkg --add-architecture i386
 RUN apt-get update
 RUN DEBIAN_FRONTEND="noninteractive" TZ="America/Los_Angeles" apt-get install -y \
    sed \
    make binutils build-essential gcc g++ bash patch gzip bzip2 perl tar cpio python unzip \
    rsync file \
    bc wget libncurses5 \
    gawk

 # time needed for the rk1808 recovery build.sh script:
 RUN apt-get install -y time

 # unbuffer from expect and cmake needed by rv1126 build script:
 RUN apt-get update
 RUN apt-get install -y expect cmake

 RUN apt-get install -y adb 
 RUN apt-get install -y python3-venv 
 RUN apt-get install -y python3-dev

 ARG UNAME=rv1126${ux}

 ARG UID=9999
 ARG GID=9999

 RUN groupadd -g \$GID \$UNAME
 RUN useradd -m -u \$UID -g \$GID -s /bin/bash \$UNAME

 RUN rm /bin/sh && ln -s bash /bin/sh
 RUN cp -a /etc /etc-original && chmod a+rw /etc

 USER \$UNAME

 CMD /bin/bash
EOF1

set -ex

echo Docker build off bb.dockerfile ...
docker build --build-arg UID=$(id -u) --build-arg GID=$(id -g) \
     -f bb.dockerfile  -t rvimg${ux} .

echo Docker build finished ...


echo
echo Creating sh-create.bash file ...

# for adb:  --priviledged -v /dev/bus/usb:/dev/bus/usb

cat << EOF2 > sh-create.bash
#!/bin/bash

if [ ! -d sharedfiles ]; then mkdir sharedfiles; fi
if [ ! -d buildfiles ]; then mkdir buildfiles; fi

    docker run -td --privileged -v /dev/bus/usb:/dev/bus/usb \\
         -v $(pwd)/sharedfiles:/home/rv1126${ux}/sharedfiles \\
         -v $(pwd)/buildfiles:/home/rv1126${ux}/buildfiles   \\
         --name rvb${ux}  rvimg${ux}

EOF2

echo Created sh-create.bash file ...


