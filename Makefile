MAKE_ROOT = $(shell while [ ! -d .git ]; do cd ..; done; pwd )

include variables.mk
SUBDIRS = reference landing

.PHONY: subdirs $(SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	@$(MAKE) -s -C $@

$(GH_PAGES):
	git clone $(MORPHIA_GITHUB) -b gh-pages $(GH_PAGES)

stage: $(GH_PAGES) all
	@$(foreach var, $(SUBDIRS), $(MAKE) -C $(var) publish;)

publish: stage
	@cd $(GH_PAGES) \
 		[ -z "$(shell git status -s)" ] \
		&& (git add . && git commit -a -m "pushing docs updates" && git push) \
		|| echo "nothing to push"

clean:
	@$(foreach var,$(SUBDIRS),$(MAKE) -s -C $(var) clean;)

mrclean:
	@$(foreach var,$(SUBDIRS),$(MAKE) -s -C $(var) mrclean;)
