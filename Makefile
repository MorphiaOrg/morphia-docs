MAKE_ROOT = $(shell while [ ! -d .git ]; do cd ..; done; pwd )

include variables.mk
SUBDIRS = critter reference landing

.PHONY: subdirs $(SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	@$(MAKE) -s -C $@

$(GH_PAGES):
	git clone $(MORPHIA_GITHUB) -b gh-pages $(GH_PAGES)
	touch $(GH_PAGES)

stage: $(GH_PAGES) all
	@$(foreach var, $(SUBDIRS), $(MAKE) -C $(var) stage;)

publish: stage
	@cd $(GH_PAGES) ; sh ../../bin/pushGhPages.sh

clean:
	@$(foreach var,$(SUBDIRS),$(MAKE) -s -C $(var) clean;)

mrclean:
	@$(foreach var,$(SUBDIRS),$(MAKE) -s -C $(var) mrclean;)
