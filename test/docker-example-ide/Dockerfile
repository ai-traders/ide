FROM alpine:3.5

# For IDE:
# * entrypoint requires sudo and bash
# * install shadow to get usermod and groupmod commands
# * add community edge repository to install shadow package
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
  apk add --no-cache bash shadow sudo

# install default IDE configs
COPY src /tmp/ide_image_scripts_src
RUN /tmp/ide_image_scripts_src/install.sh

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/bin/bash"]

# For Tests only:
# * install custom IDE configs (for tests)
# not used:
# COPY test/integration/test-files/etc_ide.d/scripts/* /etc/ide.d/scripts/
COPY etc_ide.d/variables/* /etc/ide.d/variables/

RUN echo 'ide ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
