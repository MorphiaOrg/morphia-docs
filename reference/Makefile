SUBDIRS = $(shell ls | grep [0-9]*)

.PHONY: subdirs $(SUBDIRS)

all: $(SUBDIRS)

$(SUBDIRS):
	@$(MAKE) -s -C $@

publish:
	@$(foreach var,$(SUBDIRS),$(MAKE) -s -C $(var) publish;)

clean:
	@$(foreach var,$(SUBDIRS),$(MAKE) -s -C $(var) clean;)
