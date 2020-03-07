MAKE_ROOT = $(shell while [ ! -d .git ]; do cd ..; done; pwd )
BRANCH=$(shell basename `pwd`)

include $(MAKE_ROOT)/variables.mk

$(MORPHIA_REPO):
	@[ -d $@ ] || git clone $(MORPHIA_GITHUB) --branch $(BRANCH) $@
	@[ -d overlays ] && rsync -ar overlays/* $(MORPHIA_REPO) || true

$(POM) : $(MORPHIA_REPO)

config.toml data/morphia.toml version.toml: $(POM) Makefile ../reference.mk ../version.template.toml $(COMMON_FILES)
	@rsync -ra ../common/* .

	@sed ../version.template.toml -e "s/ARTIFACT/$(ARTIFACT)/g" | \
		sed -e "s/STATUS/$(RELEASE_STATUS)/g" | \
		sed -e "s/VERSION/$(CURRENT)/g" \
		> version.toml

	@echo Updating documentation to use $(CURRENT) for the current version and a driver version of $(DRIVER).
	@sed -e "s/currentVersion.*/currentVersion = \"$(CURRENT)\"/" \
	 	-e "s/majorVersion.*/majorVersion = \"$(MAJOR)\"/" \
		-e "s|coreApiUrl.*|coreApiUrl = \"http://mongodb.github.io/mongo-java-driver/$(DRIVER)/javadoc/\"|" \
		-e "s|gitBranch.*|gitBranch = \"$(BRANCH)\"|" \
		data/morphia.toml > data/morphia.toml.sed
	@mv data/morphia.toml.sed data/morphia.toml

	@sed -e "s/baseurl.*/baseurl = \"\/$(MAJOR)\"/" \
		config.toml > config.toml.sed
	@mv config.toml.sed config.toml

	@sed -e "s|<span id=\"version-tag\">.*|<span id=\"version-tag\">$(TEXT)</span>|" \
		layouts/partials/logo.html > layouts/partials/logo.html.sed
	@mv layouts/partials/logo.html.sed layouts/partials/logo.html

$(JAVADOC)/index.html: $(shell [ -d $(CORE)/src/main/java ] && find $(CORE)/src/main/java -name *.java)
	mvn -f $(CORE) javadoc:javadoc

public/index.html: $(POM) $(shell find data) $(shell find content) $(COMMON_FILES)
	@$(HUGO)

all: public/index.html $(JAVADOC)/index.html
	@mkdir -p public/javadoc
	@rsync -ra $(JAVADOC)/ public/javadoc

publish: all
	rsync -ra --delete public/ $(GH_PAGES)/$(CURRENT)
	cd $(GH_PAGES) ; git add $(CURRENT)

watch: all
	$(HUGO) server --baseUrl=http://localhost/ --buildDrafts --watch

clean:
	@rm -rf $(shell cd ../common ; echo *) public resources version.toml

mrclean: clean
	@rm -rf $(MORPHIA_REPO)
