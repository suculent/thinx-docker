# Initial installation procedure for thinx.cloud

DOCKER ENV VARS:

THINX_HOSTNAME: 'staging.thinx.cloud'
THINX_OWNER_EMAIL: 'suculent@me.com'

### NGINX

https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-16-04
https://www.digitalocean.com/community/tutorials/how-to-set-up-password-authentication-with-nginx-on-ubuntu-14-04

### CouchDB

```
sudo apt-get install -y software-properties-common
sudo add-apt-repository ppa:couchdb/stable
sudo apt-get update
sudo apt-get install couchdb

sudo chown -R couchdb:couchdb /usr/bin/couchdb /etc/couchdb /usr/share/couchdb
sudo chmod -R 0770 /usr/bin/couchdb /etc/couchdb /usr/share/couchdb

sudo systemctl restart couchdb
```

### GIT

* GitHub Open Source access

https://github.com/suculent/thinx-device-api.git


### PIP & PlatformIO (will be moved to 2nd stage - Dockerized Builders)

    pip

You can test the builder with:

    ./build.sh --tenant=test --mac=ANY --git=https://github.com/suculent/thinx-firmware-esp8266 --dry-run

Sample log output:

    -=[ THiNX PLATFORMIO BUILDER ]=-

    Cleaning workspace...
    Cloning into 'thinx-firmware-esp8266'...
    remote: Counting objects: 14, done.
    remote: Compressing objects: 100% (9/9), done.
    remote: Total 14 (delta 4), reused 14 (delta 4), pack-reused 0
    Unpacking objects: 100% (14/14), done.
    Fetched commit ID: 18ee75e3a56c07a9eff08f75df69ef96f919653f
    
    Build step...
    [Mon Apr 10 19:25:31 2017] Processing d1_mini (platform: espressif8266, board: d1_mini, framework: arduino)
    ---------------------------------------------------------------------------------------------------
    Verbose mode can be enabled via `-v, --verbose` option
    Converting thinx-firmware-esp8266.ino
    Collected 49 compatible libraries
    Looking for dependencies...
    Library Dependency Graph
    |-- <ESP8266httpUpdate> v1.1
    |   |-- <ESP8266HTTPClient> v1.1
    |   |   |-- <ESP8266WiFi> v1.0
    |   |-- <ESP8266WiFi> v1.0
    Compiling .pioenvs/d1_mini/src/thinx-firmware-esp8266.ino.o
    Linking .pioenvs/d1_mini/firmware.elf
    Calculating size .pioenvs/d1_mini/firmware.elf
    text	   data	    bss	    dec	    hex	filename
    237497	   3256	  29672	 270425	  42059	.pioenvs/d1_mini/firmware.elf
    =================================== [SUCCESS] Took 7.42 seconds ===================================
    
    Deploying 18ee75e3a56c07a9eff08f75df69ef96f919653f.bin to /var/www/html/bin/test...


# TEST Re-build

#cd /root/Documents/Arduino/sketches/test/thinx-firmware-esp8266
#git pull origin master
#platformio run
#cp .pioenvs/d1_mini/firmware.elf /var/www/html/bin/test


## Notifications

### MQTT
https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-the-mosquitto-mqtt-messaging-broker-on-ubuntu-16-04

sudo apt-get install -y mosquitto mosquitto-clients

*Start-on-boot-fix:*

sudo update-rc.d mosquitto remove

sudo nano /etc/systemd/system/mosquitto.service

Paste and save this script

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

### Letsencrypt
    
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

-----BEGIN CERTIFICATE-----
MIIE+jCCA+KgAwIBAgISA/Qz4A0qRJiSJPLNmjbQ5tK6MA0GCSqGSIb3DQEBCwUA
MEoxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MSMwIQYDVQQD
ExpMZXQncyBFbmNyeXB0IEF1dGhvcml0eSBYMzAeFw0xNzA0MTExMDE1MDBaFw0x
NzA3MTAxMDE1MDBaMBYxFDASBgNVBAMTC3RoaW54LmNsb3VkMIIBIjANBgkqhkiG
9w0BAQEFAAOCAQ8AMIIBCgKCAQEAz4E9mo0n9BOB9VbaPVgNhIvIYu4J1iSHIcb3
HStAC0t4Xgd7R5w2nMG0OjhWdpMKkEHl9wVhkDsIuOhAeiVV3y+aMpe4lvUFiIYZ
h9+qDiTQjImpFbxRz2vWrZfUPSzH/9TzqYyW76bGXor+rolVWnJMbcRenCKezkZk
Fs78xYwb+pRQ3SujQkFuHVXTRNBRqKVk9kjF0ctqr4ha+FiLZtNAXfrYCVE+wIwE
x1MrY+w/WlzkzMoby+kcQxGQUT1GIs7FEVvygPRfEsbGDzc+5T2k6T+HpAx1RXa0
GfByuV3sQr1mIflfKTPYro3h98VX+AG11LQC/oPCAk8cR3+iwwIDAQABo4ICDDCC
AggwDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcD
AjAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBR6p33CH5YNNVbVwLfdW3pH8KD0iTAf
BgNVHSMEGDAWgBSoSmpjBH3duubRObemRWXv86jsoTBwBggrBgEFBQcBAQRkMGIw
LwYIKwYBBQUHMAGGI2h0dHA6Ly9vY3NwLmludC14My5sZXRzZW5jcnlwdC5vcmcv
MC8GCCsGAQUFBzAChiNodHRwOi8vY2VydC5pbnQteDMubGV0c2VuY3J5cHQub3Jn
LzAWBgNVHREEDzANggt0aGlueC5jbG91ZDCB/gYDVR0gBIH2MIHzMAgGBmeBDAEC
ATCB5gYLKwYBBAGC3xMBAQEwgdYwJgYIKwYBBQUHAgEWGmh0dHA6Ly9jcHMubGV0
c2VuY3J5cHQub3JnMIGrBggrBgEFBQcCAjCBngyBm1RoaXMgQ2VydGlmaWNhdGUg
bWF5IG9ubHkgYmUgcmVsaWVkIHVwb24gYnkgUmVseWluZyBQYXJ0aWVzIGFuZCBv
bmx5IGluIGFjY29yZGFuY2Ugd2l0aCB0aGUgQ2VydGlmaWNhdGUgUG9saWN5IGZv
dW5kIGF0IGh0dHBzOi8vbGV0c2VuY3J5cHQub3JnL3JlcG9zaXRvcnkvMA0GCSqG
SIb3DQEBCwUAA4IBAQAKr0met1yI3Ya0JilWSDnwN3hb8zF625t6SLFOV1Gsgjtb
MF+UhcjgTHSFJrfPzmFAjjBGwLSBo6X2tHLPuhlgGIdDSd3Jn1aclFBdvZf1ONQL
5BGAR0Lw99EQPTBemw6zCoVkRUN6Fq5Rpb6y0hsDRU/FL1tbigEKPzp49XJoqwCw
XMo8eamMweZQY2lp4+lpO1xgG0nE8cZZ3rMmvJlopPEKkh3fZ9TEgxbtO/MPhtDr
xpJBXjxGN/0PMUTFc5hYf1P9SNuuI4AVgluZC3keb893BP4IhVIiwCsvXuIVuozv
Tny2HOvn5udST4vSAA24aFzTp6Mx0NfREZwcgYHu
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIEkjCCA3qgAwIBAgIQCgFBQgAAAVOFc2oLheynCDANBgkqhkiG9w0BAQsFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTE2MDMxNzE2NDA0NloXDTIxMDMxNzE2NDA0Nlow
SjELMAkGA1UEBhMCVVMxFjAUBgNVBAoTDUxldCdzIEVuY3J5cHQxIzAhBgNVBAMT
GkxldCdzIEVuY3J5cHQgQXV0aG9yaXR5IFgzMIIBIjANBgkqhkiG9w0BAQEFAAOC
AQ8AMIIBCgKCAQEAnNMM8FrlLke3cl03g7NoYzDq1zUmGSXhvb418XCSL7e4S0EF
q6meNQhY7LEqxGiHC6PjdeTm86dicbp5gWAf15Gan/PQeGdxyGkOlZHP/uaZ6WA8
SMx+yk13EiSdRxta67nsHjcAHJyse6cF6s5K671B5TaYucv9bTyWaN8jKkKQDIZ0
Z8h/pZq4UmEUEz9l6YKHy9v6Dlb2honzhT+Xhq+w3Brvaw2VFn3EK6BlspkENnWA
a6xK8xuQSXgvopZPKiAlKQTGdMDQMc2PMTiVFrqoM7hD8bEfwzB/onkxEz0tNvjj
/PIzark5McWvxI0NHWQWM6r6hCm21AvA2H3DkwIDAQABo4IBfTCCAXkwEgYDVR0T
AQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwfwYIKwYBBQUHAQEEczBxMDIG
CCsGAQUFBzABhiZodHRwOi8vaXNyZy50cnVzdGlkLm9jc3AuaWRlbnRydXN0LmNv
bTA7BggrBgEFBQcwAoYvaHR0cDovL2FwcHMuaWRlbnRydXN0LmNvbS9yb290cy9k
c3Ryb290Y2F4My5wN2MwHwYDVR0jBBgwFoAUxKexpHsscfrb4UuQdf/EFWCFiRAw
VAYDVR0gBE0wSzAIBgZngQwBAgEwPwYLKwYBBAGC3xMBAQEwMDAuBggrBgEFBQcC
ARYiaHR0cDovL2Nwcy5yb290LXgxLmxldHNlbmNyeXB0Lm9yZzA8BgNVHR8ENTAz
MDGgL6AthitodHRwOi8vY3JsLmlkZW50cnVzdC5jb20vRFNUUk9PVENBWDNDUkwu
Y3JsMB0GA1UdDgQWBBSoSmpjBH3duubRObemRWXv86jsoTANBgkqhkiG9w0BAQsF
AAOCAQEA3TPXEfNjWDjdGBX7CVW+dla5cEilaUcne8IkCJLxWh9KEik3JHRRHGJo
uM2VcGfl96S8TihRzZvoroed6ti6WqEBmtzw3Wodatg+VyOeph4EYpr/1wXKtx8/
wApIvJSwtmVi4MFU5aMqrSDE6ea73Mj2tcMyo5jMd6jmeWUHK8so/joWUoHOUgwu
X4Po1QYz+3dszkDqMp4fklxBwXRsW10KXzPMTZ+sOPAveyxindmjkW8lGy+QsRlG
PfZ+G6Z6h7mjem0Y+iWlkYcV4PIWL1iwBi8saCbGS5jN2p8M+X+Q7UNKEkROb3N6
KOqkqm57TH2H3eDJAkSnh6/DNFu0Qg==
-----END CERTIFICATE-----


### MQTT Testing

Connect MQTT client to mqtt://thinx.cloud:8883 (SSL required, username/password required)

/home
/devices/test/00:00:00:00:00:00

node notifier.js




//sudo nano /etc/mosquitto/conf.d/default.conf

sudo echo "allow_anonymous false\npassword_file /etc/mosquitto/passwd" >> /etc/mosquitto/conf.d/default.conf

sudo systemctl restart mosquitto

// mosquitto_sub -h localhost -t test -u "guest" -P "guest" should not return error but stays hanging... how to test in CLI?


# CouchDB server (local)

sudo apt-get update
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:couchdb/stable -y
sudo apt-get update
sudo apt-get remove couchdb couchdb-bin couchdb-common -yf

Tunnelling the management port:
ssh -L5984:127.0.0.1:5984 root@iot.thinx.cloud -i ~/.ssh/DOKey2

Set default passwords and log to console (based on config.json):
iot_god | xxx
rtmadmin | xxx
rtmapi | xxx


curl -X PUT http://rtmapi:frohikey@localhost:5984/managed_devices/_design/devicelib -d @design_deviceslib.json

Create following databases:

    managed_users
    managed_devices
    managed_repos
    managed_builds


# GCM/FCM Push

Use config.

# Startup Service

    Copy the init.d script to start after boot...

    cp ./install/init.d/thinx-app /etc/init.d/

# Device API

    apt install npm nodejs-legacy # ??
    git clone https://github.com/suculent/thinx-device-api.git
    cd thinx-device-api/
    ufw allow 7442
    ufw allow 7443
    ufw allow 7444
    # and many others
        
    
# Session Store

    QUICK DEV START:
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


# Node.js

# The App

# CRONs and background jobs

# Restart

