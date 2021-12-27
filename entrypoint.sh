#!/bin/bash

VERSION="1.18.1"
BUILD="103"
FILENAME="paper-${VERSION}-${BUILD}.jar"
URL="https://papermc.io/api/v2/projects/paper/versions/${VERSION}/builds/${BUILD}/downloads/${FILENAME}"

set_server_prop() {
  local prop=$1
  local envName=$2

  if [ -v $envName ]; then
    local value="${!envName}"
    sed -i "/^${prop}\s*=/ c ${prop}=${value//\\/\\\\}" /data/server.properties
  fi
}

shutdown_handler() {
  rcon-cli --config /data/.rcon-cli.yaml say "Shutting down server!"
  rcon-cli --config /data/.rcon-cli.yaml save-all
  rcon-cli --config /data/.rcon-cli.yaml stop

  sleep 2
}

trap 'shutdown_handler' SIGTERM

cd /data

if [ ! -f "server.properties" ]; then
  cp /server.properties .
  cp /eula.txt .
  cp /ops.json .
  cp /whitelist.json .
  cp /server-icon.png .
fi

set_server_prop "rcon.password" RCON_PASSWORD

if [ ! -f "${FILENAME}" ]; then
  echo "downloading ${FILENAME}..."
  wget --quiet --output-document="${FILENAME}" "${URL}"
fi

echo "starting minecraft with ${FILENAME}..."
JAVA_OPTS="-Xms2G -Xmx2G"
java $JAVA_OPTS -jar "${FILENAME}" --nogui &
pid="$!"

wait "$pid"
