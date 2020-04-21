#! /bin/sh

cd $(GH_PAGES)


if [ "$(git status -s)" != "" ]
then
  echo git commit -a -m "pushing docs updates"
  echo git push
else
  echo "nothing to push"
fi