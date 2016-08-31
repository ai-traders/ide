FROM ubuntu:14.04.2

RUN apt-get update && \
  apt-get install -y --no-install-recommends git ca-certificates && \
  rm -rf /var/cache/apt/*
RUN git clone https://github.com/sstephenson/bats.git && bats/install.sh /usr/local

# make ide scripts available in Docker build context, so that we can
# install them later (using install.sh)
COPY src /tmp/ide_image_scripts_src
