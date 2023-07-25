#!/bin/bash

function extract() {
  mvn -q build-helper:parse-version \
    help:evaluate -Dexpression=parsedVersion.$1 -q -DforceStdout
}

export BRANCH=$1
export MINOR_ONLY=$2
cd build/morphia
git checkout $BRANCH &> /dev/null || echo checkout failed for $BRANCH

MAJOR=`extract majorVersion`
MINOR=`extract minorVersion`
PATCH=`extract incrementalVersion`

if [ $PATCH != "0" ]
then
  PATCH=$[ $PATCH -1 ]
else
  QUALIFIER="-SNAPSHOT"
fi

[ "$MINOR_ONLY" ] && echo "$MAJOR.$MINOR" || echo "$MAJOR.$MINOR.$PATCH$QUALIFIER" 
