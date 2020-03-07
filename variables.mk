.PHONY: all
.DEFAULT_GOAL := all

GH_PAGES=/tmp/gh_pages
MORPHIA_GITHUB=git@github.com:MorphiaOrg/morphia.git
MORPHIA_REPO=/tmp/morphia-for-docs-$(BRANCH)
POM = $(MORPHIA_REPO)/pom.xml
MAVEN_HELP = org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate
CURRENT = $(shell mvn -f $(POM) $(MAVEN_HELP) -Dexpression=project.version | grep -v INFO | sed -e 's/^r//' )
ARTIFACT = $(shell mvn -f $(CORE)/pom.xml $(MAVEN_HELP) -Dexpression=project.artifactId | grep -v INFO | sed -e 's/^r//' )
DRIVER = $(shell mvn -f $(POM) $(MAVEN_HELP) -Dexpression=driver.version | grep -v INFO)
HUGO = hugo --themesDir=$(MAKE_ROOT)/themes
COMMON_FILES=$(shell find $(MAKE_ROOT)/reference/common/)
RELEASE_STATUS = $(shell [ "`echo $(BRANCH) | grep '^r'`" ] && echo "current" || echo "development" )

MAJOR = $(shell echo ${CURRENT} | sed -e 's/-SNAPSHOT//')
SRC_LINK = "https://github.com/MorphiaOrg/morphia/tree/$(BRANCH)"
TEXT = Morphia $(CURRENT)
CORE = $(MORPHIA_REPO)/morphia
BUILD_PLUGINS = $(MORPHIA_REPO)/build-plugins
UTIL = $(MORPHIA_REPO)/util
JAVADOC = $(CORE)/target/site/apidocs
