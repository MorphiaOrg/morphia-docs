MAKE_ROOT = $(shell while [ ! -d .git ]; do cd ..; done; pwd )

include $(MAKE_ROOT)/variables.mk

data/releases.toml: $(shell find ../reference | grep -v public) ../bin/branches.sh
	@sh ../bin/branches.sh

public/index.html: $(shell find . | grep -v public)
	@$(HUGO)

all: data/releases.toml public/index.html

publish: all
	@rm -r $(GH_PAGES)/[a-z0-9]*
	@rsync -ra public/ $(GH_PAGES)

watch: all
	$(HUGO) server --baseUrl=http://localhost/ --buildDrafts --watch

clean:
	rm -rf public