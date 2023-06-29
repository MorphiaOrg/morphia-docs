#!/bin/bash

function extract() {
  mvn -f build/morphia/pom.xml \
    build-helper:parse-version \
    help:evaluate -Dexpression=parsedVersion.$1 -q -DforceStdout
}

MAJOR=`extract majorVersion`
MINOR=`extract minorVersion`
PATCH=`extract incrementalVersion`

if [ $PATCH != "0" ]
then
  PATCH=$[ $PATCH -1 ]
else
  QUALIFIER="-SNAPSHOT"
fi

echo $MAJOR > build/majorVersion
echo $MINOR > build/minorVersion
echo $PATCH > build/patchVersion

echo "$MAJOR.$MINOR.$PATCH$QUALIFIER" > build/fullVersion
