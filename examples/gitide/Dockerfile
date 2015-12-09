FROM debian:8.2
MAINTAINER Ewa Czechowska <ewa@ai-traders.com>

COPY scripts/* /usr/bin/

RUN useradd -d /home/ide -p pass -s /bin/bash -u 1000 -m ide &&\
    chmod 755 /usr/bin/ide-fix-uid-gid.sh &&\
    chmod 755 /usr/bin/ide-setup-identity.sh &&\
    chmod 755 /usr/bin/entrypoint.sh &&\
    chown ide:ide -R /home/ide

ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/bin/bash"]
