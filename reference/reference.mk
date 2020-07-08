MAKE_ROOT = $(shell while [ ! -d .git ]; do cd ..; done; pwd )
BRANCH=$(shell basename `pwd`)

include $(MAKE_ROOT)/variables.mk

VERSION_GITHUB=$(MORPHIA_GITHUB)
MORPHIA_REPO=$(REPO_ROOT)/morphia/$(BRANCH)
POM = $(MORPHIA_REPO)/pom.xml
CORE = $(MORPHIA_REPO)/morphia
MAVEN_HELP = org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate
HUGO_CONFIG_FILES=config.toml data/morphia.toml version.toml

CURRENT = $(shell mvn -f $(POM) $(MAVEN_HELP) -Dexpression=project.version | grep -v "^\[" | grep -v "Download" )
ARTIFACT = $(shell mvn -f $(CORE)/pom.xml $(MAVEN_HELP) -Dexpression=project.artifactId | grep -v "^\[" | grep -v "Download" )
DRIVER = $(shell mvn -f $(POM) $(MAVEN_HELP) -Dexpression=driver.version | grep -v "^\[" | grep -v "Download" )
RELEASE_STATUS = $(shell [ "`echo $(BRANCH) | grep '^r'`" ] && echo "current" || echo "development" )

TEXT = Morphia $(CURRENT)
BUILD_PLUGINS = $(MORPHIA_REPO)/build-plugins
UTIL = $(MORPHIA_REPO)/util
JAVADOC = $(CORE)/target/site/apidocs

$(MORPHIA_REPO):
	@[ -d $@ ] || git clone $(VERSION_GITHUB) --branch $(BRANCH) $@

$(POM) : $(MORPHIA_REPO) $(shell [ -d overlays ] && find overlays )
	@cd $(MORPHIA_REPO) && git reset --hard origin && git checkout $(BRANCH)
	@[ -d overlays ] && rsync -var overlays/* $(MORPHIA_REPO) || true

data/morphia.toml: $(MAKE_ROOT)/variables.mk Makefile
	@mkdir -p data
	@echo "artifactId = \"$(ARTIFACT)\"" > data/morphia.toml
	@echo "coreApiUrl = \"$(CORE_API_URL)\"" >> data/morphia.toml
	@echo "currentVersion = \"$(CURRENT)\"" >> data/morphia.toml
	@echo "gitBranch = \"$(BRANCH)\"" >> data/morphia.toml

config.toml: $(MAKE_ROOT)/reference/config.template.toml
	@sed -e "s/baseUrl.*/baseUrl = \"\/$(CURRENT)\"/" $(MAKE_ROOT)/reference/config.template.toml > config.toml

version.toml: $(MAKE_ROOT)/reference/version.template.toml $(COMMON_FILES)
	@rsync -ra $(MAKE_ROOT)/reference/common/* .

	@sed $(MAKE_ROOT)/reference/version.template.toml -e "s/ARTIFACT/$(ARTIFACT)/g" | \
		sed -e "s/STATUS/$(RELEASE_STATUS)/g" | \
		sed -e "s/VERSION/$(CURRENT)/g" > version.toml

public/javadoc/index.html: $(POM) $(shell [ -d $(CORE)/src/main/java ] && find $(CORE)/src/main/java -name *.java)
	@[ -d $(BUILD_PLUGINS) ] && mvn -f $(BUILD_PLUGINS) install -DskipTests || true
	@mvn -f $(UTIL) install -DskipTestsk
	@mvn -f $(CORE) clean javadoc:javadoc
	@mkdir -p public/javadoc
	@rsync -ra --delete $(JAVADOC)/ public/javadoc

public/index.html: $(shell find content) $(COMMON_FILES) $(HUGO_CONFIG_FILES)
	@rsync -ra $(MAKE_ROOT)/reference/common/* .
	@sed -e "s|<span id=\"version-tag\">.*|<span id=\"version-tag\">$(TEXT)</span>|" \
		layouts/partials/logo.html > layouts/partials/logo.html.sed
	@mv layouts/partials/logo.html.sed layouts/partials/logo.html

	$(HUGO)

all: $(POM) public/index.html public/javadoc/index.html

stage: all
	@rsync -ra --delete public/ $(GH_PAGES)/$(CURRENT)
	@cd $(GH_PAGES) ; git add $(CURRENT)

watch: all
	@$(HUGO) server --baseUrl=http://localhost/ --buildDrafts --watch

clean:
	@rm -rf $(shell cd $(MAKE_ROOT)/reference/common ; echo *) public resources config.toml version.toml data

mrclean: clean
	@rm -rf $(MORPHIA_REPO)
