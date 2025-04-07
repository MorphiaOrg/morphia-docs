#!/usr/bin/env bash

> Makefile-javadoc

M2_PATH="~/.m2/repository/dev/morphia/morphia/"

DOCS=""
while read -r VERSION
do
  if [[ $VERSION != 1.* ]]
  then
    ARTIFACT=morphia-core
  else
    ARTIFACT=core
  fi
  SHORTVER=` echo $VERSION | cut -d. -f-2 `

  if [ "${VERSION/-SNAPSHOT/}" != "${VERSION}" ]
  then
    REPO="https://oss.sonatype.org/content/repositories/snapshots/"
    echo "build/site/morphia/$SHORTVER/javadoc/index.html: .PHONY
	@mkdir -p build/site/morphia/$SHORTVER/javadoc/
	@echo Checking for a new snapshot for $SHORTVER
	@mvn -q -U dependency:get -DgroupId=dev.morphia.morphia -DartifactId=${ARTIFACT} -Dversion=${VERSION} \\
		-Dclassifier=javadoc -DremoteRepositories=${REPO} -Dtransitive=false
	@echo Extracting javadoc for $SHORTVER
	@unzip -DD -q -o ${M2_PATH}${ARTIFACT}/${VERSION}/${ARTIFACT}-${VERSION}-javadoc.jar \\
		-d build/site/morphia/$SHORTVER/javadoc/ ;
" >> Makefile-javadoc

  else

    REPO=https://repo1.maven.org/maven2

    echo "${M2_PATH}${ARTIFACT}/${VERSION}/${ARTIFACT}-${VERSION}-javadoc.jar:
	@echo Fetching artifacts for ${SHORTVER}
	@mvn -q -U dependency:get -DgroupId=dev.morphia.morphia -DartifactId=${ARTIFACT} -Dversion=${VERSION} \\
		-Dclassifier=javadoc -DremoteRepositories=${REPO} -Dtransitive=false
" >> Makefile-javadoc

    echo "build/site/morphia/$SHORTVER/javadoc/index.html: ${M2_PATH}${ARTIFACT}/${VERSION}/${ARTIFACT}-${VERSION}-javadoc.jar
	@echo Extracting javadoc for $SHORTVER
	@mkdir -p build/site/morphia/$SHORTVER/javadoc/
	@unzip -DD -q -o ${M2_PATH}${ARTIFACT}/${VERSION}/${ARTIFACT}-${VERSION}-javadoc.jar \\
		-d build/site/morphia/$SHORTVER/javadoc/ ;
" >> Makefile-javadoc

  fi


DOCS="$DOCS build/site/morphia/$SHORTVER/javadoc/index.html"
done < versions.list

cat << EOF >> Makefile-javadoc
alldocs: ${DOCS}
.PHONY:
EOF
