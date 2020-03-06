include ../variables.mk

data/releases.toml: $(shell find ../reference | grep -v public)
	@sh ../bin/branches.sh

public/index.html: $(shell find . | grep -v public)
	@$(HUGO)

all: data/releases.toml public/index.html

publish: all
	rsync -ra public/ ../../target/gh-pages/

watch: all
	$(HUGO) server --baseUrl=http://localhost/ --buildDrafts --watch

clean:
	rm -rf public