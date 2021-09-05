#!/bin/bash

VERSION="1.17.1"
BUILD="249"
FILENAME="paper-${VERSION}-${BUILD}.jar"
URL="https://papermc.io/api/v2/projects/paper/versions/${VERSION}/builds/${BUILD}/downloads/${FILENAME}"

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
java $JAVA_OPTS -jar "${FILENAME}" --nogui
