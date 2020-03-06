#! /bin/sh

> data/releases.toml
for i in ../reference/*
do
  if [ -d $i/content ]
  then
    make -C $i -s version.toml
    cat $i/version.toml >> data/releases.toml
    echo >> data/releases.toml
  fi
done