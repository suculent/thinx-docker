# Installing platform builders

### PIP & PlatformIO

    so


### ESP8266

    mkdir -p ~/Documents/Arduino/hardware
    mkdir esp8266com
    cd esp8266com
    git clone https://github.com/esp8266/Arduino.git esp8266
    cd esp8266/tools
    python get.py
    
    ## Platformio Builder

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
    
# Micropython setup


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


# Mongoose OS builder


[Docs](https://github.com/cesanta/mongoose-os/blob/master/docs/apps/build.md)

Install MongooseOS bundle:
        
    curl -fsSL https://mongoose-os.com/downloads/mos/install.sh | /bin/bash    


Build custom instance:

    mos update

    cd ~/tools/mos # (or current user's build folder

    ~/.mos/bin/mos init --verbose

    mos build --verbose
    
    # TODO: Fetch custom user data
