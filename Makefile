# Uncomment for verbose debug output
#__ORIGINAL_SHELL:=$(SHELL)
#SHELL=$(warning [[ Building $@$(if $<, (from $<))$(if $?, ($? newer)) ]] )$(TIME) $(__ORIGINAL_SHELL)

GH_PAGES=gh_pages
BRANCHES=master 2.5.x 2.4.x 1.6.x
PLAYBOOK=antora-playbook.yml

default: site sync

$(GH_PAGES): .PHONY
	@[ ! -d $@ ] && gh repo clone MorphiaOrg/morphia $(GH_PAGES) -- -b gh-pages || true
	@git -C $@ reset --hard --quiet && git -C $@ pull --all --quiet

build/morphia: .PHONY
	@[ ! -d $@ ] && gh repo clone MorphiaOrg/morphia build/morphia || true
	@git -C $@ pull --all --quiet

package-lock.json: package.json
	@npm run clean-install

versions.list: Makefile bin/syncVersions.kt
	@echo Extracting versions
	@make -s build/morphia
	@> versions.list
	@for BRANCH in $(BRANCHES); \
	do \
	  git -C build/morphia checkout $$BRANCH --quiet || echo checkout failed for $$BRANCH ; \
	  git -C build/morphia pull --rebase --quiet || echo update failed for $$BRANCH ; \
	  jbang bin/syncVersions.kt $$BRANCH >> versions.list ; \
	done;
	@git -C build/morphia checkout master --quiet || echo checkout failed for $$BRANCH

	@BRANCH=`echo $(BRANCHES) | cut -d' ' -f 2` ; \
	git -C build/morphia checkout $$BRANCH --quiet || echo checkout failed for $$BRANCH ; \
	VERSION=`jbang bin/syncVersions.kt $$BRANCH onlyminor` ; \
	sed -i $@ -e "s|../morphia/.*/index.html|../morphia/$$VERSION/index.html|"

antora-playbook.yml: Makefile .PHONY
	@sed antora-playbook-template.yml \
		-e "s/branches: \[.*\] ### morphia branches/branches: [ `echo $(BRANCHES) | sed -e 's/ /, /g'` ] ### morphia branches/" > $@

local: antora-playbook.yml
	@sed -i -e 's!^  - url: https://github.com/MorphiaOrg/\(.*\)!  - url: ../\1!' antora-playbook.yml

Makefile-javadoc: versions.list bin/generate-makefile.sh Makefile
	@bash ./bin/generate-makefile.sh

javadocs: Makefile Makefile-javadoc
	@$(MAKE) -f Makefile-javadoc alldocs

$(GH_PAGES)/index.html: $(GH_PAGES) build/site/index.html
	@cd $(GH_PAGES) ; \
		rsync -Cra --delete --exclude=CNAME --exclude=.git ../build/site/ . ; \
		git add .

push:
	@cd $(GH_PAGES) ; \
		git commit -a -m "pushing docs updates" ; \
		git pull --rebase ; \
		git push

site: versions.list package-lock.json javadocs
	@make -s $(PLAYBOOK)
	@npm run build
	@touch build/site/.nojekyll
	@cp home/modules/ROOT/pages/*.html build/site/landing

sync: $(GH_PAGES)/index.html

publish: site sync push

clean:
	@rm -rf antora-playbook.yml versions.list Makefile-javadoc

mrclean: clean
	@rm -rf build $(GH_PAGES)
	@npm run clean

.PHONY: