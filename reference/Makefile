SUBDIRS = $(shell find . -maxdepth 1 -type d | grep / | grep -v common)

.PHONY: subdirs $(SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	@$(MAKE) -s -C $@

publish:
	@$(foreach var,$(SUBDIRS),$(MAKE) -s -C $(var) publish;)

clean:
	@$(foreach var,$(SUBDIRS),$(MAKE) -s -C $(var) clean;)
