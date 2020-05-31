SUBDIRS = $(shell find . -maxdepth 1 -type d | grep / | grep -v common)

.PHONY: subdirs $(SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	@$(MAKE) -s -C $@

stage:
	@$(foreach var,$(SUBDIRS),$(MAKE) -s -C $(var) stage;)

clean:
	@$(foreach var,$(SUBDIRS),$(MAKE) -s -C $(var) clean;)

mrclean:
	@$(foreach var,$(SUBDIRS),$(MAKE) -s -C $(var) mrclean;)
