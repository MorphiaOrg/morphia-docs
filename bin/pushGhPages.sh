#! /bin/sh

if [ "$(git status -s)" != "" ]
then
  git commit -a -m "pushing docs updates"
  git push
else
  echo "nothing to push"
fi
