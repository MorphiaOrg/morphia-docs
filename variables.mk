.PHONY: all
.DEFAULT_GOAL := all

GH_PAGES=/tmp/gh_pages
MORPHIA_GITHUB=git@github.com:MorphiaOrg/morphia.git
MORPHIA_REPO=/tmp/morphia-for-docs
POM = $(MORPHIA_REPO)/pom.xml
MAVEN_HELP = org.apache.maven.plugins:maven-help-plugin:2.1.1:evaluate
CURRENT = $(shell mvn -f $(POM) $(MAVEN_HELP) -Dexpression=project.version | grep -v INFO)
DRIVER = $(shell mvn -f $(POM) $(MAVEN_HELP) -Dexpression=driver.version | grep -v INFO)
HUGO = hugo --themesDir=$(MAKE_ROOT)/themes

MAJOR = $(shell echo ${CURRENT} | sed -e 's/-SNAPSHOT//' -e 's/.[0-9]*$$//')
SRC_LINK = "https://github.com/MorphiaOrg/morphia/tree/$(BRANCH)"
TEXT = Morphia $(MAJOR)
CORE = $(MORPHIA_REPO)/morphia
JAVADOC = $(CORE)/target/site/apidocs
