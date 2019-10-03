FROM ubuntu:16.04
MAINTAINER best "https://github.com/best7766"
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

RUN echo exit 0 > /usr/sbin/policy-rc.d
RUN chmod +x /usr/sbin/policy-rc.d

ENV TZ 'Europe/Tallinn'
    RUN echo $TZ > /etc/timezone && \
    apt-get update && apt-get install -y tzdata && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    apt-get clean
    
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install lsof && \
    apt-get -y install vim && \
    apt-get -y install wget && \
    apt-get -y install apt-transport-https && \
    apt-get -y install gnupg2 && \
    apt-get -y install net-tools && \
    apt-get -y install libssl-dev && \
    apt-get -y install libcurl4-openssl-dev && \
    apt-get -y install libxml2-dev && \
    apt-get -y install uuid-runtime && \
    apt-get -y install git && \
    apt-get -y install apache2 apache2-doc apache2-utils && \
    apt-get -y install apache2-dev && \
    apt-get -y install tar && \
    apt-get -y install curl && \
    apt-get -y install nano && \
    apt-get -y install gzip && \
    apt-get -y install dialog && \
    apt-get -y install build-essential && \
    apt-get -y install openssh-server && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*


RUN apt-get -y update && \
	DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common apt-transport-https && \
	curl -fsSL https://dl.winehq.org/wine-builds/Release.key | apt-key add - && \
	dpkg --add-architecture i386 && \
	add-apt-repository https://dl.winehq.org/wine-builds/ubuntu/ && \
	apt-get -y update && \
	DEBIAN_FRONTEND=noninteractive apt-get -y install --install-recommends winehq-stable

# Install packages

ENV DEBIAN_FRONTEND noninteractive
RUN sed -i "s/# deb-src/deb-src/g" /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -yy upgrade
ENV BUILD_DEPS="git autoconf pkg-config libssl-dev libpam0g-dev \
    libx11-dev libxfixes-dev libxrandr-dev nasm xsltproc flex \
    bison libxml2-dev dpkg-dev libcap-dev xserver-xorg-dev"
RUN apt-get -yy install \ 
	sudo apt-utils software-properties-common vim wget ca-certificates \
    xauth supervisor uuid-runtime pulseaudio locales xserver-xorg \
    $BUILD_DEPS


# Build xrdp

WORKDIR /tmp
RUN apt-get source pulseaudio
RUN apt-get build-dep -yy pulseaudio
WORKDIR /tmp/pulseaudio-8.0
RUN dpkg-buildpackage -rfakeroot -uc -b
WORKDIR /tmp
RUN git clone --branch v0.9.4 --recursive https://github.com/neutrinolabs/xrdp.git
WORKDIR /tmp/xrdp
RUN ./bootstrap
RUN ./configure
RUN make
RUN make install
WORKDIR /tmp/xrdp/sesman/chansrv/pulse
RUN sed -i "s/\/tmp\/pulseaudio\-10\.0/\/tmp\/pulseaudio\-8\.0/g" Makefile 
RUN make
RUN cp *.so /usr/lib/pulse-8.0/modules/

# Build xorgxrdp

WORKDIR /tmp
RUN git clone --branch v0.2.4 --recursive https://github.com/neutrinolabs/xorgxrdp.git
WORKDIR /tmp/xorgxrdp
RUN ./bootstrap
RUN ./configure
RUN make
RUN make install

# Clean 

WORKDIR /
RUN apt-get -yy remove xscreensaver
RUN apt-get -yy remove $BULD_DEPS
RUN apt-get -yy autoremove
RUN apt-get -yy clean
RUN rm -rf /tmp/*

# Configure
ADD etc /etc
ADD bin /usr/bin
RUN mkdir /var/run/dbus
RUN cp /etc/X11/xrdp/xorg.conf /etc/X11
RUN sed -i "s/xrdp\/xorg/xorg/g" /etc/xrdp/sesman.ini
RUN locale-gen en_US.UTF-8


# Clean preconfigured stuff

RUN rm -rf /etc/xrdp/rsakeys.ini /etc/xrdp/rsakeys.ini /etc/xrdp/*.pem 

RUN echo 'root:root123' |chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN mkdir /root/.ssh
# Docker config

VOLUME ["/etc","/home"]
EXPOSE 3389 9001 22 80
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["supervisord"]
