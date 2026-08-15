FROM eclipse-temurin:25

RUN apt-get update \
  && apt-get install -y wget jq \
  && apt-get clean

ADD server.properties /
ADD eula.txt /
ADD ops.json /
ADD whitelist.json /
ADD server-icon.png /
ADD plugins /plugins

RUN mkdir -p /data
RUN chown ubuntu /data

RUN mkdir /tmp/rcon-cli \
  && cd /tmp/rcon-cli \
  && wget -q https://github.com/itzg/rcon-cli/releases/download/1.7.6/rcon-cli_1.7.6_linux_amd64.tar.gz \
  && tar -xf rcon-cli_1.7.6_linux_amd64.tar.gz \
  && cp rcon-cli /usr/local/bin \
  && cd / \
  && rm -rf /tmp/rcon-cli

USER ubuntu

ENV RCON_PORT=25575

ADD entrypoint.sh /

EXPOSE 25565

ENTRYPOINT ["/entrypoint.sh"]
