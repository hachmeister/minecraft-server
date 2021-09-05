FROM openjdk:17-slim

RUN apt-get update \
  && apt-get install -y wget \
  && apt-get clean

RUN useradd --create-home --shell /bin/bash minecraft

ADD server.properties /
ADD eula.txt /
ADD ops.json /
ADD whitelist.json /

RUN mkdir -p /data
RUN chown minecraft /data

USER minecraft

ADD entrypoint.sh /

EXPOSE 25565

ENTRYPOINT ["/entrypoint.sh"]
