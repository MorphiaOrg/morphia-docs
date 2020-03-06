include variables.mk
SUBDIRS = landing reference

.PHONY: subdirs $(SUBDIRS) ../target

all: $(SUBDIRS)

$(SUBDIRS):
	@$(MAKE) -s -C $@

$(GH_PAGES):
	git clone $(MORPHIA_GITHUB) -b gh-pages $(GH_PAGES)

publish: all $(GH_PAGES)
	@cd $(GH_PAGES) ; git pull
	@$(foreach var, $(SUBDIRS), $(MAKE) -C $(var) publish;)
	#cd $(GH_PAGES) ; git add . && git commit -a -m "pushing docs updates"
	#cd $(GH_PAGES) && git push

clean:
	@$(foreach var,$(SUBDIRS),$(MAKE) -s -C $(var) clean;)
	@rm -rf $(GH_PAGES)
