FROM ubuntu
MAINTAINER suculent

# If you want to tinker with this Dockerfile on your machine do as follows:
# - git clone https://github.com/suculent/thinx-docker
# - vim thinx-docker/Dockerfile
# - docker build -t thinx-docker thinx-docker
# - cd <thinx-docker>
# - docker run --rm -ti -v `pwd`:/opt/thinx-device-api thinx-docker

RUN apt-get update && apt-get install -y wget unzip git make python-serial srecord bc
CMD echo
