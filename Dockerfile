FROM frodon1/debian:latest-salome8
MAINTAINER <frodon1@gmail.com>

ENV SALOMEROOT /opt/salome
ENV SALOMEVERSION V8_2_0

COPY salome_yamm.py /opt/salome_yamm.py
COPY yamm_docker.tar.gz /tmp

RUN mkdir -p /opt/salome \
 && tar xzf /tmp/yamm_docker.tar.gz -C /opt \
 && rm -f /tmp/yamm_docker.tar.gz \
 && python /opt/salome_yamm.py

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]
