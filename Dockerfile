FROM ubuntu:16.04
MAINTAINER best "https://github.com/best7766"
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

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
    apt-get -y install sudo && \
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
    apt-get -y install supervisor && \
    apt-get autoclean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*
	
# Installing Kubuntu Desktop & its Dependencies
RUN sudo apt-get -y install xorg xrdp build-essential tasksel
RUN sudo DEBIAN_FRONTEND=noninteractive tasksel install kubuntu-desktop
RUN sudo service xrdp restart

# Setting Up Kubuntu Desktop
RUN sudo apt-get -y install nemo gedit
RUN sudo xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
RUN sudo apt-get -y purge dolphin kate gwenview
RUN sudo xdg-mime default gedit.desktop text/plain
RUN sudo rm -f /*/Desktop/trash.desktop
RUN sudo rm -f /*/*/Desktop/trash.desktop
RUN sudo apt-get autoclean
RUN sudo apt-get autoremove

# Installing WINE to run Windows Applications
RUN sudo dpkg --add-architecture i386
RUN sudo wget -nc https://dl.winehq.org/wine-builds/winehq.key
RUN sudo apt-key add winehq.key
RUN sudo apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/
RUN sudo apt-get update
RUN sudo apt-get install --install-recommends winehq-devel -y
RUN sudo apt-get install winetricks -y
	

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
	
RUN wget -P /usr/sbin/ https://dl.eff.org/certbot-auto \
    && chmod a+x /usr/sbin/certbot-auto	

EXPOSE 3389 9001 22 80 443 10000
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["supervisord"]
