#!/bin/bash

VERSION="26.2"
BUILD="112"
FILENAME="paper-${VERSION}-${BUILD}.jar"
URL="https://fill.papermc.io/v3/projects/paper/versions/${VERSION}/builds/${BUILD}"

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

  wget --quiet --output-document=paper_build.js "${URL}"
  PAPER_URL=$(jq -r '.downloads."server:default".url' paper_build.js)

  wget --quiet --output-document="${FILENAME}" "${PAPER_URL}"

  rm paper_build.js
fi

echo "installing mods..."
mkdir -p plugins
rm plugins/*.jar
cp /plugins/*.jar plugins

echo "starting minecraft with ${FILENAME}..."
PAPER_OPTS="-XX:+AlwaysPreTouch -XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32"
JAVA_OPTS="-Xms2G -Xmx2G"
java $JAVA_OPTS $PAPER_OPTS -jar "${FILENAME}" --nogui &
pid="$!"

wait "$pid"
