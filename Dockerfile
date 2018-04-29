FROM debian


## General package configuration
RUN apt-get -y update && \
    apt-get -y install \
        sudo \
        unzip \
        curl \
        xmlstarlet \
        netcat-traditional \
        software-properties-common \
        debconf-utils \
        uuid-runtime \
        ncurses-bin \
        iputils-ping \
        net-tools \
        jq \
        zip \
        python \
        openssh-server \
        openssh-client \
        apt-transport-https \
        wget \
        vim \
        sysstat \
        xinetd


RUN echo "deb https://dl.bintray.com/rerun/rerun-deb /" >> /etc/apt/sources.list
#RUN apt-get -y install rerun-beeroclock


#SSH support
RUN mkdir /var/run/sshd
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config


RUN mkdir -p /var/lib/beeroclock
COPY lib/server /var/lib/beeroclock
COPY lib/server/xinetd.d/beeroclock /etc/xinetd.d/beeroclock

RUN echo "beeroclock 28080/tcp           # beer time web service" >> /etc/services
RUN touch /var/log/beeroclock.log

EXPOSE 28080

CMD service xinetd start && tail -f /var/log/beeroclock.log

