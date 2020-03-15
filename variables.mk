.PHONY: all
.DEFAULT_GOAL := all

REPO_ROOT=$(MAKE_ROOT)/repos

GH_PAGES=$(REPO_ROOT)/gh_pages

MORPHIA_GITHUB=git@github.com:MorphiaOrg/morphia.git

COMMON_FILES=$(shell find $(MAKE_ROOT)/reference/common -type f )
HUGO = hugo --themesDir=$(MAKE_ROOT)/themes

