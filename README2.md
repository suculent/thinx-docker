# 2. Installing platform builders

Because this operation takes a while and will hardly fail, it's separated to the Second Stage of Installation.

## Installing Platform Builders

Enter the container with bash:

```
docker run -ti -e THINX_HOSTNAME='staging.thinx.cloud' -e THINX_OWNER='suculent@me.com' suculent/thinx-docker /bin/bash

```

Fetch required builder images from Docker Hub:

```
bash ./install-builders.sh
```


## TODOs and Notes
Everything should be dockerized. Docker should be run as builder. Params should be packed to JSON before running from shared folder.


# NodeMCU Custom Firmware Builder

Requires Docker.

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce

mkdir tools
cd tools
git clone https://github.com/nodemcu/nodemcu-firmware.git
curl https://github.com/nodemcu/nodemcu-firmware/blob/master/tools/esp-open-sdk.tar.xz

ln -s ~/thinx-device-api/tools/nodemcu-firmware/ .
cd tools
ln -s nodemcu-firmware/tools/esp-open-sdk.tar.xz ./esp-open-sdk.tar.xz
docker run --rm -ti -v `pwd`:/opt/nodemcu-firmware marcelstoer/nodemcu-build

// # git clone --recursive https://github.com/pfalcon/esp-open-sdk.git


Ubuntu 14.04:

$ sudo apt-get install make unrar-free autoconf automake libtool gcc g++ gperf \
    flex bison texinfo gawk ncurses-dev libexpat-dev python-dev python python-serial \
    sed git unzip bash help2man wget bzip2
Later Debian/Ubuntu versions may require:

$ sudo apt-get install libtool-bin



# NodeMCU Build Config

http://nodemcu.readthedocs.io/en/master/en/build/cd 

### LUA Modules

..
bh1750
bmp085
dht_lib
ds18b20
ds3231
email
hdc1000
http
lm92
mcp23008
redis
si7021
tsl2561
yeelink


## Firmware Modules

coap
crypto
dhtlib
driver
esp-gdbstub
fatfs
http
include
libc
lua
lwip
mbedtls
misc
modules
mqtt
net
pcm
platform
pm
sjson
smart
spiffs
swTimer
task
tsl2561
u8glib
ucglib
user

## ALL Modules by nodemcu-build.com:

ADC 
ADS1115 
ADXL345 
AM2320 
APA102 
bit 
BME280 
BMP085 
CoAP 
Cron 
crypto 
DHT 
encoder 
end user setup 
file 
gdbstub 
GPIO 
HDC1080 
HMC5883L 
HTTP 
HX711 
I²C 
L3G4200D 
mDNS 
MQTT 
net 
node 
1-Wire 
PCM 
perf 
PWM 
RC (no docs)
rfswitch 
rotary 
RTC fifo 
RTC mem 
RTC time 
Si7021 
Sigma-delta 
SJSON 
SNTP 
Somfy 
SPI 
struct 
Switec 
TCS34725 
TM1829 
timer 
TSL2561 
U8G 
UART 
UCG 
websocket 
WiFi 
WPS 
WS2801 
WS2812 
XPT2046 


