.PHONY: all
.DEFAULT_GOAL := all

HUGO = hugo --themesDir=$(MAKE_ROOT)/themes

MORPHIA_GITHUB=git@github.com:MorphiaOrg/morphia.git
GH_PAGES=/tmp/gh_pages
MORPHIA_REPO=/tmp/morphia-for-docs-$(BRANCH)

POM = $(MORPHIA_REPO)/pom.xml
MAVEN_HELP = org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate
SRC_LINK = "https://github.com/MorphiaOrg/morphia/tree/$(BRANCH)"

FILTER='grep -v "^\[" | grep -v "Download" '
MAJOR = $(shell echo ${CURRENT} | sed -e 's/-SNAPSHOT//')
CURRENT = $(shell mvn -f $(POM) $(MAVEN_HELP) -Dexpression=project.version | grep -v "^\[" | grep -v "Download" )
ARTIFACT = $(shell mvn -f $(CORE)/pom.xml $(MAVEN_HELP) -Dexpression=project.artifactId | grep -v "^\[" | grep -v "Download" )
DRIVER = $(shell mvn -f $(POM) $(MAVEN_HELP) -Dexpression=driver.version | grep -v "^\[" | grep -v "Download" )
RELEASE_STATUS = $(shell [ "`echo $(BRANCH) | grep '^r'`" ] && echo "current" || echo "development" )

COMMON_FILES=$(shell find $(MAKE_ROOT)/reference/common -type f )
PUBLISH_FILES=$(GH_PAGES)/$(CURRENT)/index.html
HUGO_CONFIG_FILES=config.toml data/morphia.toml version.toml

TEXT = Morphia $(CURRENT)
CORE = $(MORPHIA_REPO)/morphia
BUILD_PLUGINS = $(MORPHIA_REPO)/build-plugins
UTIL = $(MORPHIA_REPO)/util
JAVADOC = $(CORE)/target/site/apidocs
