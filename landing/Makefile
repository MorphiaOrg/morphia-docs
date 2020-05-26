MAKE_ROOT = $(shell while [ ! -d .git ]; do cd ..; done; pwd )

include $(MAKE_ROOT)/variables.mk

data/releases.toml: $(shell find $(MAKE_ROOT)/reference -name version.toml ) $(MAKE_ROOT)/bin/branches.sh
	@MAKE_ROOT=$(MAKE_ROOT) sh $(MAKE_ROOT)/bin/branches.sh

public/index.html: $(shell find . | grep -v public)
	@$(HUGO)

all: data/releases.toml public/index.html

publish: all
	@rm -rf $(GH_PAGES)/[a-z]*
	@rsync -ra public/ $(GH_PAGES)

watch: all
	$(HUGO) server --baseUrl=http://localhost/ --buildDrafts --watch

clean:
	rm -rf public

mrclean: clean
	@rm -rf $(GH_PAGES)
