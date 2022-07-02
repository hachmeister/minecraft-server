#!/bin/bash

MINECRAFT_VERSION="1.18.2"
FABRIC_INSTALLER_VERSION="0.11.0"
FABRIC_INSTALLER_URL="https://maven.fabricmc.net/net/fabricmc/fabric-installer/${FABRIC_INSTALLER_VERSION}/fabric-installer-${FABRIC_INSTALLER_VERSION}.jar"

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

MINECRAFT_CURRENT_VERSION=""

if [[ -f "server.jar" ]] ; then
  MINECRAFT_CURRENT_VERSION="$(unzip -p server.jar version.json | jq -r ".name")"
fi

if [[ "${MINECRAFT_VERSION}" != "${MINECRAFT_CURRENT_VERSION}" ]] ; then
  echo "Downloading Fabric installer ${FABRIC_INSTALLER_VERSION}..."
  wget --quiet --output-document="installer.jar" "${FABRIC_INSTALLER_URL}"
  
  echo "Installing Fabric server for Minecraft ${MINECRAFT_VERSION}..."
  java -jar installer.jar server -mcversion 1.18.2 -downloadMinecraft
  rm installer.jar
fi

echo "starting minecraft with ${FILENAME}..."
JAVA_OPTS="-Xms2G -Xmx2G"
java $JAVA_OPTS -jar fabric-server-launch.jar --nogui &
pid="$!"

wait "$pid"
