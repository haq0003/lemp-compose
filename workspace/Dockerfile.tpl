FROM    ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade

RUN apt-get -y --no-install-recommends update && \
apt-get -y --no-install-recommends install \
apt-utils apt-transport-https gnupg2 ca-certificates rsync unzip locales \
vim nano sudo curl openssl libssl-dev git mysql-client  \
ssh build-essential wget apache2 apache2-doc apache2-utils \
libapache2-mod-php php7.2 php7.2-common php7.2-gd php7.2-mysql \
php7.2-imap phpmyadmin php7.2-cli php7.2-cgi libapache2-mod-fcgid \
apache2-suexec-pristine php-pear mcrypt  imagemagick libruby \
libapache2-mod-python php7.2-curl php7.2-intl php7.2-pspell php7.2-recode \
php7.2-sqlite3 php7.2-tidy php7.2-xmlrpc php7.2-xsl memcached php-memcache php-imagick \
php-gettext php7.2-zip php7.2-mbstring php-soap php7.2-soap \
php-xdebug \
# install python
&& apt-get install -y python-pip && \
apt-get install -y python3 && apt-get install -y python3-pip

RUN locale-gen en_US.UTF-8
RUN export LANG=C.UTF-8
RUN export LC_ALL=C.UTF-8

# composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# yarn & node
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN curl -sL https://deb.nodesource.com/setup_9.x | bash -
RUN apt-get update -yqq && apt-get -yqq --fix-missing install nodejs yarn

#####################################
# CONF APACHE:
#####################################

RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf
ENV APACHE_RUN_USER [[PUSER]]
ENV APACHE_RUN_GROUP client0
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid

#####################################
# Non-Root User:
#####################################

ARG PUID=[[PUID]]
ARG PGID=[[GUID]]

ENV PUID ${PUID}
ENV PGID ${PGID}

RUN groupadd -g ${PGID} [[PGGROUP]] && \
useradd  -u ${PUID} -g [[PGGROUP]] -m -d "/home/[[PUSER]]" [[PUSER]] && \
usermod -s /bin/bash [[PUSER]] && \
apt-get update -yqq

RUN mkdir -p /var/www/html && \
mkdir /home/[[PUSER]]/.ssh && \
mkdir /var/run/sshd

# SSH login fix. Otherwise user is kicked off after login
#ref https://engineering.riotgames.com/news/jenkins-ephemeral-docker-tutorial
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
#to pass environment variables when running a Dockerized SSHD service.
#SSHD scrubs the environment, therefore ENV variables contained in Dockerfile
#must be pushed to /etc/profile in order for them to be available.
ENV NOTVISIBLE "in users profile"

RUN echo "export VISIBLE=now" >> /etc/profile

RUN echo "root:[[ROOT_PASS]]" | chpasswd
RUN echo "[[PUSER]]:[[USERNAME]]_[[SUFF_PASS]]" | chpasswd

EXPOSE 22
EXPOSE 80

CMD /etc/init.d/ssh start && \
/etc/init.d/apache2 start && \
/bin/bash

WORKDIR /var/www