
#FROM scratch
#ADD ubuntu-xenial-core-cloudimg-amd64-root.tar.gz /

FROM debian:jessie-backports
ARG DEBIAN_FRONTEND=noninteractive
ARG THINX_HOSTNAME
MAINTAINER suculent

# If you want to tinker with this Dockerfile on your machine do as follows:
# - git clone https://github.com/suculent/thinx-docker
# - vim thinx-docker/Dockerfile
# - docker build -t thinx-docker thinx-docker
# - cd <thinx-docker>
# - docker run --rm -ti -v `pwd`:/opt/thinx-device-api thinx-docker

# docker run -ti -e THINX_HOSTNAME='staging.thinx.cloud' -e THINX_OWNER='suculent@me.com' suculent/thinx-docker

# 1. Get own Google Firebase Notifications key and store into conf/FCM.json.
#    This project contains only revoked development key.

# 2. Replace 'staging.thinx.cloud' in conf/conf.json with your own FQDN.
#    This chould be done with an env var and sed.

RUN echo "Environment variable THINX_HOSTNAME: ${THINX_HOSTNAME}"

# Those variables should be overridden!!!
ENV THINX_HOSTNAME staging.thinx.cloud
ENV THINX_OWNER_EMAIL suculent@me.com

RUN echo Installing as hostname: ${THINX_HOSTNAME} && echo With Letsencrypt owner: ${THINX_OWNER_EMAIL} && export THINX_HOSTNAME=staging.thinx.cloud \
 && apt-get update && apt-get install -y letsencrypt -t jessie-backports \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /etc/letsencrypt/live/${THINX_HOSTNAME} \
 && openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/letsencrypt/live/${THINX_HOSTNAME}/privkey.pem \
    -out /etc/letsencrypt/live/${THINX_HOSTNAME}/fullchain.pem \
    -subj /CN=${THINX_HOSTNAME}

RUN ["/bin/bash", "-c", "debconf-set-selections <<< \"postfix postfix/mailname string ${THINX_HOSTNAME}\" \
&& debconf-set-selections <<< \"postfix postfix/main_mailer_type string 'Internet Site'\""]

RUN apt-get update && apt-get -y install software-properties-common apt-utils \
 && apt-get install -y curl\
 git \
 make \
 mailutils \
 mosquitto \
 mosquitto-clients \
 netcat \
 nginx \
 postfix \
 pwgen \
 redis-server \
 wget \
 unzip

RUN apt-get install -y --force-yes \
     build-essential \
     erlang-dev \
     erlang-manpages \
     erlang-base-hipe \
     erlang-eunit \
     erlang-nox \
     erlang-xmerl \
     erlang-inets \
     libmozjs185-dev \
     libicu-dev \
     libcurl4-gnutls-dev \
     libtool && \
     cd /tmp && \
     wget https://www-eu.apache.org/dist/couchdb/source/1.6.1/apache-couchdb-1.6.1.tar.gz && \
     tar xzvf apache-couchdb-1.6.1.tar.gz && \
     cd apache-couchdb-1.6.1 && \
     ./configure && \
     make && \
     make install && \
     sed -e 's/^bind_address = .*$/bind_address = 0.0.0.0/' -i /usr/local/etc/couchdb/default.ini && \
     sed -e 's/^database_dir = .*$/database_dir = \/data/' -i /usr/local/etc/couchdb/default.ini && \
     sed -e 's/^view_index_dir = .*$/view_index_dir = \/data/' -i /usr/local/etc/couchdb/default.ini && \
     apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Recently added corrent installation of nodejs 8.x
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
 && apt-get install -y nodejs \
 && curl -k -O -L https://npmjs.org/install.sh \
 && if [[ ! -f /usr/bin/node ]]; then ln -s /usr/bin/nodejs /usr/bin/node; fi \
 && mkdir -p /root/thinx-device-api \
 && cd /root \
 && git clone https://github.com/suculent/thinx-device-api.git \
 && cd ./thinx-device-api \
 && npm install forever -g \
 && node -v \
 && npm install .

ADD scripts /scripts
RUN chmod +x /scripts/*.sh
RUN touch /.firstrun

# Copy configuration JSONs
COPY ./conf/*.json /root/thinx-device-api/conf/

# Default Redis configuration
COPY ./conf/redis.conf /etc/redis/redis.conf


# MQTT
EXPOSE 1883
EXPOSE 8883

# THiNX
EXPOSE 7442
EXPOSE 7443

# Webhooks
EXPOSE 9000
EXPOSE 9001

# Nginx
EXPOSE 80
EXPOSE 443

# Default command to execute at runtime
ENTRYPOINT ["/scripts/run.sh"]
