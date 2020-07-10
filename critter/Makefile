MAKE_ROOT = $(shell while [ ! -d .git ]; do cd ..; done; pwd )
BRANCH=r4.0.0

include $(MAKE_ROOT)/variables.mk

VERSION_GITHUB=git@github.com:MorphiaOrg/critter.git

CRITTER_REPO=$(REPO_ROOT)/critter/$(BRANCH)
POM = $(CRITTER_REPO)/pom.xml
MAVEN_HELP = org.apache.maven.plugins:maven-help-plugin:3.2.0:evaluate
HUGO_CONFIG_FILES=config.toml data/critter.toml

CURRENT = $(shell mvn -f $(POM) $(MAVEN_HELP) -Dexpression=project.version | grep -v "^\[" | grep -v "Download" )
TEXT = Critter $(CURRENT)

$(CRITTER_REPO):
	@[ -d $@ ] || git clone $(VERSION_GITHUB) --branch $(BRANCH) $@

$(POM) : $(CRITTER_REPO)
	@[ -z "$(shell echo $(BRANCH) | grep '^r')" ] && (cd $(CRITTER_REPO) ; git pull) || true

public/index.html: $(shell find content) $(COMMON_FILES) $(HUGO_CONFIG_FILES)
	rsync -ra $(MAKE_ROOT)/reference/common/* .
	sed -e "s|<span id=\"version-tag\">.*|<span id=\"version-tag\">$(TEXT)</span>|" \
		layouts/partials/logo.html > layouts/partials/logo.html.sed
	mv layouts/partials/logo.html.sed layouts/partials/logo.html

	$(HUGO)

all: $(POM) public/index.html

stage: all
	rsync -ra --delete public/ $(GH_PAGES)/critter
	cd $(GH_PAGES) ; git add critter

watch: all
	$(HUGO) server --baseUrl=http://localhost/ --buildDrafts --watch

clean:
	rm -rf $(shell cd $(MAKE_ROOT)/reference/common ; echo *) public resources

mrclean: clean
	rm -rf $(CRITTER_REPO)
