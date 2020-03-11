MAKE_ROOT = $(shell while [ ! -d .git ]; do cd ..; done; pwd )
BRANCH=$(shell basename `pwd`)

include $(MAKE_ROOT)/variables.mk

$(MORPHIA_REPO):
	[ -d $@ ] || git clone $(MORPHIA_GITHUB) --branch $(BRANCH) $@
	[ -d overlays ] && rsync -ar overlays/* $(MORPHIA_REPO) || true

$(POM) : $(MORPHIA_REPO)

data/morphia.toml: $(POM) Makefile $(MAKE_ROOT)/reference/reference.mk
	mkdir -p data
	echo "artifactId = \"$(ARTIFACT)\"" > data/morphia.toml
	echo "coreApiUrl = \"$(CORE_API_URL)\"" >> data/morphia.toml
	echo "currentVersion = \"$(CURRENT)\"" >> data/morphia.toml
	echo "gitBranch = \"$(BRANCH)\"" >> data/morphia.toml

config.toml: $(POM) Makefile $(MAKE_ROOT)/reference/reference.mk $(MAKE_ROOT)/reference/config.template.toml
	sed -e "s/baseUrl.*/baseUrl = \"\/$(CURRENT)\"/" $(MAKE_ROOT)/reference/config.template.toml > config.toml

version.toml: $(POM) Makefile $(MAKE_ROOT)/reference/reference.mk \
	$(MAKE_ROOT)/reference/version.template.toml $(COMMON_FILES)
	rsync -ra $(MAKE_ROOT)/reference/common/* .

	sed $(MAKE_ROOT)/reference/version.template.toml -e "s/ARTIFACT/$(ARTIFACT)/g" | \
		sed -e "s/STATUS/$(RELEASE_STATUS)/g" | \
		sed -e "s/VERSION/$(CURRENT)/g" > version.toml

$(JAVADOC)/index.html: $(shell [ -d $(CORE)/src/main/java ] && find $(CORE)/src/main/java -name *.java)
	[ -d $(BUILD_PLUGINS) ] && mvn -f $(BUILD_PLUGINS) install -DskipTests || true
	mvn -f $(UTIL) install -DskipTestsk
	mvn -f $(CORE) javadoc:javadoc

sync:
	rsync -ra $(MAKE_ROOT)/reference/common/* .

public/index.html: $(POM) $(shell find content) $(COMMON_FILES) $(HUGO_CONFIG_FILES)
	rsync -ra $(MAKE_ROOT)/reference/common/* .
	sed -e "s|<span id=\"version-tag\">.*|<span id=\"version-tag\">$(TEXT)</span>|" \
		layouts/partials/logo.html > layouts/partials/logo.html.sed
	mv layouts/partials/logo.html.sed layouts/partials/logo.html

	$(HUGO)

all: public/index.html $(JAVADOC)/index.html
	mkdir -p public/javadoc
	rsync -ra $(JAVADOC)/ public/javadoc

publish: all
	rsync -ra --delete public/ $(GH_PAGES)/$(CURRENT)
	cd $(GH_PAGES) ; git add $(CURRENT)

watch: all
	$(HUGO) server --baseUrl=http://localhost/ --buildDrafts --watch

clean:
	rm -rf $(shell cd $(MAKE_ROOT)/reference/common ; echo *) public resources version.toml data/morphia.toml

mrclean: clean
	rm -rf $(MORPHIA_REPO)
