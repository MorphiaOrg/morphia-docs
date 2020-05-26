#! /bin/sh

echo root = ${MAKE_ROOT}
RELEASES=${MAKE_ROOT}/landing/data/releases.toml
mkdir -p data
> data/releases.toml
cd ${MAKE_ROOT}/reference
VERSIONS=`find . -maxdepth 1 -type d | cut -c3- | grep 'r[0-9]'`
VERSIONS="$VERSIONS `find . -maxdepth 1 -type d | cut -c3- | grep ^[^r]`"
for i in $VERSIONS
do
  VERSION=$i
  if [ -d ${VERSION}/content ]
  then
    echo Processing version data for $i
    make -C ${VERSION} -s version.toml
    cat ${VERSION}/version.toml >> ${RELEASES}
    echo >> ${RELEASES}
  fi
done