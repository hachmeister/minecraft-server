FROM openjdk:17-slim

RUN apt-get update \
  && apt-get install -y jq rsync unzip wget \
  && apt-get clean

RUN useradd --create-home --shell /bin/bash minecraft

ADD server.properties /
ADD eula.txt /
ADD ops.json /
ADD whitelist.json /
ADD server-icon.png /

RUN mkdir -p /data
RUN chown minecraft /data

RUN mkdir /tmp/rcon-cli \
  && cd /tmp/rcon-cli \
  && wget -q https://github.com/itzg/rcon-cli/releases/download/1.5.1/rcon-cli_1.5.1_linux_amd64.tar.gz \
  && tar -xf rcon-cli_1.5.1_linux_amd64.tar.gz \
  && cp rcon-cli /usr/local/bin \
  && cd / \
  && rm -rf /tmp/rcon-cli

USER minecraft

ENV RCON_PORT=25575

ADD entrypoint.sh /

EXPOSE 25565

ENTRYPOINT ["/entrypoint.sh"]
