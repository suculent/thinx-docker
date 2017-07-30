# Initial installation procedure for thinx.cloud

DOCKER ENV VARS:

    THINX_HOSTNAME: 'staging.thinx.cloud'
    THINX_OWNER_EMAIL: 'suculent@me.com'

### NGINX

# https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-16-04

    sudo apt-get update
    sudo apt-get install nginx
    sudo ufw allow 'Nginx HTTP'
    sudo systemctl start nginx

### CouchDB

    sudo apt-get install -y software-properties-common
    sudo add-apt-repository ppa:couchdb/stable
    sudo apt-get update
    sudo apt-get install couchdb

    sudo chown -R couchdb:couchdb /usr/bin/couchdb /etc/couchdb /usr/share/couchdb
    sudo chmod -R 0770 /usr/bin/couchdb /etc/couchdb /usr/share/couchdb

    sudo systemctl restart couchdb
    

### Python

# a requirement for platformio



## Notifications

# https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-the-mosquitto-mqtt-messaging-broker-on-ubuntu-16-04

sudo apt-get install -y mosquitto mosquitto-clients

# *Start-on-boot-fix:*

# sudo update-rc.d mosquitto remove
# sudo nano /etc/systemd/system/mosquitto.service

Paste and save this script

```
[Unit]
Description=Mosquitto MQTT Broker
Documentation=man:mosquitto(8)
Documentation=man:mosquitto.conf(5)
ConditionPathExists=/etc/mosquitto/mosquitto.conf
After=xdk-daemon.service

[Service]
ExecStart=/usr/sbin/mosquitto -c /etc/mosquitto/mosquitto.conf
ExecReload=/bin/kill -HUP $MAINPID
User=mosquitto
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
sudo systemctl enable mosquitto.service
sudo reboot

check if mosquitto is running

sudo mosquitto -v
```

## Letsencrypt
    
    sudo add-apt-repository ppa:certbot/certbot
    sudo apt-get update -y
    sudo apt-get install -y certbot
    sudo ufw allow http
    service apache2 stop
    sudo certbot certonly --standalone --standalone-supported-challenges http-01 -d ${THINX_HOSTNAME} << echo ${THINX_OWNER_EMAIL} # TODO: automate agree, yes!
    service apache2 start
    
    sudo crontab -e << echo '15 3 * * * certbot renew --noninteractive --post-hook "systemctl restart mosquitto"'
    
    sudo mosquitto_passwd -c /etc/mosquitto/passwd guest << "echo guest\nguest"
    
    sudo nano /etc/mosquitto/conf.d/default.conf
    
    listener 1883 localhost
    
    listener 8883
    certfile /etc/letsencrypt/live/${THINX_HOSTNAME}/cert.pem
    cafile /etc/letsencrypt/live/${THINX_HOSTNAME}/chain.pem
    keyfile /etc/letsencrypt/live/${THINX_HOSTNAME}/privkey.pem
    
    sudo systemctl restart mosquitto
    sudo ufw allow 8883
    
    mosquitto_pub -h iot.teacloud.net -t test -m "hello again" -p 8883 --capath /etc/ssl/certs/ -u "guest" -P "guest" // does not lock in CLI, cool.



    sudo nano /etc/mosquitto/conf.d/default.conf
    sudo echo "allow_anonymous false\npassword_file /etc/mosquitto/passwd" >> /etc/mosquitto/conf.d/default.conf
    sudo systemctl restart mosquitto

    # mosquitto_sub -h localhost -t test -u "guest" -P "guest" should not return error but stays hanging... how to test in CLI?


# CouchDB server (local)

    sudo apt-get update
    sudo apt-get install software-properties-common -y
    sudo add-apt-repository ppa:couchdb/stable -y
    sudo apt-get update
    sudo apt-get remove couchdb couchdb-bin couchdb-common -yf

Set default passwords and log to console (based on config.json):

    rtmadmin | xxx
    rtmapi | xxx


curl -X PUT http://rtmapi:frohikey@localhost:5984/managed_devices/_design/devicelib -d @design_deviceslib.json
# etc...

# Create following databases:

```
    managed_users
    managed_devices
    managed_repos
    managed_builds
```

# GCM/FCM Push

Use config...

# Startup Service

    # TODO: standard bootup instead of pm2 for Docker image
    
    # Copy the init.d script to start after boot...

    cp ./install/init.d/thinx-app /etc/init.d/

# Device API

    apt install npm nodejs-legacy # why legacy?
    git clone https://github.com/suculent/thinx-device-api.git
    cd thinx-device-api/
    ufw allow 7442
    ufw allow 7443
    ufw allow 7444
    # and many others... (1883/8883 for mqtt, 9000/9001 for githooks,...???)
        
    
# Session Store

    sudo apt-get install -y redis-server
    redis-server &
    
    PRODUCTION SERVICE:
    curl -O http://download.redis.io/redis-stable.tar.gz
    tar xzvf redis-stable.tar.gz
    make; make test; sudo make install    
    sudo mkdir /etc/redis
    sudo cp redis.conf /etc/redis
    sudo nano /etc/redis/redis.conf
    
    change to `supervised systemd`
    and `dir /var/lib/redis`
    
    sudo nano /etc/systemd/system/redis.service
    
```
[Unit]
Description=Redis In-Memory Data Store
After=network.target

[Service]
User=redis
Group=redis
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
ExecStop=/usr/local/bin/redis-cli shutdown
Restart=always

[Install]
WantedBy=multi-user.target
```

    sudo adduser --system --group --no-create-home redis
    sudo mkdir /var/lib/redis
    sudo chown redis:redis /var/lib/redis


# Logrotate

    # todo: use pm2 logrotate...
    sudo chmod 775 thinx.log 
    root@thinx:/var/log# sudo chown syslog:adm thinx.log 

# Postfix

    sudo apt install mailutils


# SPF/DKIM

Your domain DNS and mailserver should have valid SPF/DKIM setup to prevent activation and password-reset e-mails being rejected as spam.

*TODO: Add link*

# Node.js

# The App

# CRONs and background jobs

# Restart

