MAKE_ROOT = $(shell while [ ! -d .git ]; do cd ..; done; pwd )

include $(MAKE_ROOT)/variables.mk
LANDING_FILES = $(shell ls public )

data/releases.toml: $(shell find $(MAKE_ROOT)/reference -name version.toml ) $(MAKE_ROOT)/bin/branches.sh
	@MAKE_ROOT=$(MAKE_ROOT) sh $(MAKE_ROOT)/bin/branches.sh

public/index.html: $(shell find . | grep -v public)
	@$(HUGO)

all: data/releases.toml public/index.html

stage: all
	@rsync -ra public/ $(GH_PAGES)
	@cd $(GH_PAGES)/ ; git add $(LANDING_FILES)

watch: all
	$(HUGO) server --baseUrl=http://localhost/ --buildDrafts --watch

clean:
	rm -rf public

mrclean: clean
	@rm -rf $(GH_PAGES)
