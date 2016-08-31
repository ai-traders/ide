FROM ubuntu:14.04.2

RUN apt-get update && \
  apt-get install -y --no-install-recommends git ca-certificates && \
  rm -rf /var/cache/apt/*
RUN git clone --depth 1 https://github.com/sstephenson/bats.git && \
  git clone --depth 1 https://github.com/ztombol/bats-support.git && \
  git clone --depth 1 https://github.com/ztombol/bats-assert.git && \
  /bats/install.sh /usr/local

# make ide scripts available in Docker build context, so that we can
# install them later (using install.sh)
COPY src /tmp/ide_image_scripts_src
