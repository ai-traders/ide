FROM debian:8.2
MAINTAINER Ewa Czechowska <ewa@ai-traders.com>

COPY scripts/* /usr/bin/

# entrypoint requires sudo and it should be first installed, then set
RUN apt-get update && apt-get install -y git sudo && apt-get -y autoremove && \
  apt-get -y autoclean && \
  apt-get -y clean && \
  rm -rf /tmp/* /var/tmp/* && \
  rm -rf /var/lib/apt/lists/*

RUN useradd -d /home/ide -p pass -s /bin/bash -u 1000 -m ide &&\
    chmod 755 /usr/bin/ide-fix-uid-gid.sh &&\
    chmod 755 /usr/bin/ide-setup-identity.sh &&\
    chmod 755 /usr/bin/entrypoint.sh &&\
    echo 'ide ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers &&\
    chown ide:ide -R /home/ide

# add image metadata
RUN touch /etc/docker_metadata.txt && \
    VERSION=$(cat /usr/bin/docker_image_version.txt) && \
    echo "base_image_name=\"debian\"\n\
base_image_tag=\"8.2\"\n\
this_image_name=\"gitide\"\n\
this_image_tag=\"${VERSION}\"\n\
" >> /etc/docker_metadata.txt

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/bin/bash"]
