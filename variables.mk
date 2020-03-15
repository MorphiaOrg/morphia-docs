.PHONY: all
.DEFAULT_GOAL := all

HUGO = hugo --themesDir=$(MAKE_ROOT)/themes

MORPHIA_GITHUB=git@github.com:MorphiaOrg/morphia.git
GH_PAGES=/tmp/gh_pages

SRC_LINK = "https://github.com/MorphiaOrg/morphia/tree/$(BRANCH)"

COMMON_FILES=$(shell find $(MAKE_ROOT)/reference/common -type f )
HUGO_CONFIG_FILES=config.toml data/morphia.toml version.toml

