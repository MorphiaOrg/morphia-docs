#!/usr/bin/env bash

cat << EOF > Makefile-javadoc
M2_PATH=~/.m2/repository/dev/morphia/morphia

EOF

DOCS=""
while read -r VERSION
do
  if [[ $VERSION != 1.* ]]
  then
    ARTIFACT=morphia-core
  else
    ARTIFACT=core
  fi
  SHORTVER=$( echo $VERSION | cut -d. -f-2 )

  if [ "${VERSION/-SNAPSHOT/}" != "${VERSION}" ]
  then
    REPO="https://oss.sonatype.org/content/repositories/snapshots/"
    PHONY=".PHONY"
  else
    REPO=https://repo1.maven.org/maven2
    PHONY=""
  fi

  echo "\$(M2_PATH)/${ARTIFACT}/${VERSION}/${ARTIFACT}-${VERSION}-javadoc.jar: ${PHONY}
	@echo Fetching artifacts for ${VERSION}
	@mvn -q -U dependency:get -Dartifact=dev.morphia.morphia:${ARTIFACT}:${VERSION}:jar:javadoc \\
	  -DremoteRepositories=${REPO} -Dtransitive=false

build/site/morphia/$SHORTVER/javadoc/index.html: \$(M2_PATH)/${ARTIFACT}/${VERSION}/${ARTIFACT}-${VERSION}-javadoc.jar
	@echo Extracting javadoc for ${VERSION}
	@mkdir -p build/site/morphia/$SHORTVER/javadoc/
	@unzip -DD -q -o \$(M2_PATH)/${ARTIFACT}/${VERSION}/${ARTIFACT}-${VERSION}-javadoc.jar \\
		-d build/site/morphia/$SHORTVER/javadoc/
" >> Makefile-javadoc



DOCS="$DOCS build/site/morphia/$SHORTVER/javadoc/index.html"
done < versions.list

cat << EOF >> Makefile-javadoc
alldocs: ${DOCS}

.PHONY:
EOF
