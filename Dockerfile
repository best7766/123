FROM       danielguerra69/ubuntu-xrdp-base
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

RUN echo 'root:root123' |chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN mkdir /root/.ssh

RUN echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
RUN echo "deb http://webmin.mirror.somersettechsolutions.co.uk/repository sarge contrib" >> /etc/apt/sources.list
RUN wget -q http://www.webmin.com/jcameron-key.asc -O- | sudo apt-key add -
RUN rm /etc/apt/apt.conf.d/docker-gzip-indexes
RUN apt-get -o Acquire::GzipIndexes=false update -y
RUN apt-get install apt-show-versions -y
RUN apt-get update && apt-get install webmin -y
RUN yes | /usr/share/webmin/authentic-theme/theme-update.sh
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Install some tools required for creating the image
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		curl \
		unzip \
		ca-certificates

# Install wine and related packages
RUN dpkg --add-architecture i386 \
		&& apt-get update \
		&& apt-get install -y --no-install-recommends \
				wine \
				wine32 \
		&& rm -rf /var/lib/apt/lists/*

# Use the latest version of winetricks
RUN curl -SL 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks' -o /usr/local/bin/winetricks \
		&& chmod +x /usr/local/bin/winetricks

# Get latest version of mono for wine
RUN mkdir -p /usr/share/wine/mono \
	&& curl -SL 'http://sourceforge.net/projects/wine/files/Wine%20Mono/$WINE_MONO_VERSION/wine-mono-$WINE_MONO_VERSION.msi/download' -o /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi \
	&& chmod +x /usr/share/wine/mono/wine-mono-$WINE_MONO_VERSION.msi  
  
  


RUN /usr/bin/service apache2 start
RUN /usr/bin/service webmin start


EXPOSE 22
EXPOSE 80
EXPOSE 10000

CMD    ["/usr/sbin/sshd", "-D"]
