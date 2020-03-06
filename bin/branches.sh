#! /bin/sh

for i in ../reference/[0-9]*
do
  make -C $i -s version.toml
  cat $i/version.toml > data/releases.toml
done