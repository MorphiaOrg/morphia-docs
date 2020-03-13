#! /bin/sh

mkdir -p data
> data/releases.toml
for i in r1.5.8 r1.4.1 r2.0.0-BETA1 1.5.x master
do
  VERSION=../reference/$i
  if [ -d ${VERSION}/content ]
  then
    echo Processing $i
    make -C ${VERSION} -s version.toml
    cat ${VERSION}/version.toml | tee -a data/releases.toml
    echo >> data/releases.toml
  fi
done