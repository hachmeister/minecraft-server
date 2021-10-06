#!/bin/bash

VERSION="1.17.1"
BUILD="304"
FILENAME="paper-${VERSION}-${BUILD}.jar"
URL="https://papermc.io/api/v2/projects/paper/versions/${VERSION}/builds/${BUILD}/downloads/${FILENAME}"

shutdown_handler() {
  rcon-cli --config /data/.rcon-cli.yaml say "Shutdown in 10 seconds!"

  sleep 10

  rcon-cli --config /data/.rcon-cli.yaml save-all
  rcon-cli --config /data/.rcon-cli.yaml stop
}

trap 'shutdown_handler' SIGTERM

cd /data

if [ ! -f "server.properties" ]; then
  cp /server.properties .
  cp /eula.txt .
  cp /ops.json .
  cp /whitelist.json .
fi

if [ ! -f "${FILENAME}" ]; then
  echo "downloading ${FILENAME}..."
  wget --quiet --output-document="${FILENAME}" "${URL}"
fi

echo "starting minecraft with ${FILENAME}..."
JAVA_OPTS="-Xms2G -Xmx2G"
java $JAVA_OPTS -jar "${FILENAME}" --nogui &
pid="$!"

wait "$pid"
