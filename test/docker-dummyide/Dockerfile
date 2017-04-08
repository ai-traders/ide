FROM alpine:3.5
MAINTAINER Ewa Czechowska <ewa@ai-traders.com>

COPY src/ /tmp/ide_image_scripts/src/

# * entrypoint requires sudo and shadow, shadow needs edge repository
# * install bash just for tests and because I am used to it (it is small)
# * write to /etc/ide.d/variables/99.sh because this_image_name is set to
# ideide, so in order not to confuse
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
 apk add --no-cache bash shadow sudo && \
 /tmp/ide_image_scripts/src/install.sh && \
 echo -e "#!/bin/bash\nexport this_image_name=\"dummyide\"\nexport this_image_tag=\"0.0.1\"" >> /etc/ide.d/variables/99.sh &&\
 chmod 775 /etc/ide.d/variables/99.sh &&\
 echo 'ide ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/bin/bash"]
