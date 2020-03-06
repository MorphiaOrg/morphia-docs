SUBDIRS = $(shell ls | grep [0-9]*)

.PHONY: subdirs $(SUBDIRS) ../target

all: $(SUBDIRS)

$(SUBDIRS):
	@ echo $(MAKE) -s -C $@