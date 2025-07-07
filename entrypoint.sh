#!/bin/bash

VERSION="1.21.7"
BUILD="17"
FILENAME="paper-${VERSION}-${BUILD}.jar"
URL="https://api.papermc.io/v2/projects/paper/versions/${VERSION}/builds/${BUILD}/downloads/${FILENAME}"

copy_file() {
  local filename=$1

  if [ ! -f "/data/$filename" ]; then
    cp "/$filename" "/data/"
  fi
}

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

copy_file "server.properties"
copy_file "eula.txt"
copy_file "ops.json"
copy_file "whitelist.json"
copy_file "server-icon.png"

set_server_prop "rcon.password" RCON_PASSWORD

cd /data

if [ ! -f "${FILENAME}" ]; then
  echo "downloading ${FILENAME}..."
  wget --quiet --output-document="${FILENAME}" "${URL}"
fi

echo "installing mods..."
mkdir -p plugins
rm plugins/*.jar
cp /plugins/*.jar plugins

echo "starting minecraft with ${FILENAME}..."
JAVA_OPTS="-Xms2G -Xmx2G"
java $JAVA_OPTS -jar "${FILENAME}" --nogui &
pid="$!"

wait "$pid"
