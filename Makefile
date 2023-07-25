MORPHIA_GITHUB=https://evanchooly:${{ secrets.PUSH_TOKEN }}github.com/MorphiaOrg/morphia.git
GH_PAGES=gh_pages
BRANCHES=master 2.4.x 2.3.x 2.2.x 2.1.x 1.6.x
PLAYBOOK=antora-playbook.yml

default: site sync

$(GH_PAGES): .PHONY
	[ ! -d $ ] && git clone $(MORPHIA_GITHUB) -b gh-pages $(GH_PAGES) || true
	git -C $ reset --hard --quiet && git -C $ pull --all --quiet

build/morphia: .PHONY
	[ ! -d $ ] && git clone $(MORPHIA_GITHUB) build/morphia || true
	git -C $ pull --all --quiet

versions.list: Makefile 
	echo Extracting versions
	> versions.list
	for BRANCH in $(BRANCHES); \
	do \
	  git -C build/morphia checkout $$BRANCH &> /dev/null || echo checkout failed for $$BRANCH ; \
	  jbang --quiet bin/extractVersions.kt $$BRANCH >> versions.list ; \
	done;
	git -C build/morphia checkout master &> /dev/null || echo checkout failed for $$BRANCH ; \

local: .PHONY
	$(eval PLAYBOOK=local-${PLAYBOOK} )

home/modules/ROOT/pages/index.html : Makefile Makefile-javadoc build/morphia
	BRANCH=`echo $(BRANCHES) | cut -d' ' -f 2` ; \
	git -C build/morphia checkout $$BRANCH &> /dev/null || echo checkout failed for $$BRANCH ; \
	VERSION=`jbang --quiet bin/extractVersions.kt $$BRANCH onlyminor` ; \
	sed -i $ -e "s|../morphia/.*/index.html|../morphia/$$VERSION/index.html|"

antora-playbook.yml: Makefile .PHONY
	sed antora-playbook-template.yml \
		-e "s/branches: \[.*\] ### morphia branches/branches: [ `echo $(BRANCHES) | sed -e 's/ /, /g'` ] ### morphia branches/" > $

local-antora-playbook.yml: antora-playbook.yml Makefile
	sed -i -e 's!^  - url: https://github.com/MorphiaOrg/\(.*\)!  - url: ../\1!' antora-playbook.yml

site: build/morphia versions.list home/modules/ROOT/pages/index.html package-lock.json
	make -s $(PLAYBOOK)
	npm run build
	touch build/site/.nojekyll
	cp home/modules/ROOT/pages/*.html build/site/landing

sync: $(GH_PAGES)/index.html

publish: site sync push

Makefile-javadoc: versions.list bin/generate-makefile.sh
	bash ./bin/generate-makefile.sh

javadocs: Makefile Makefile-javadoc
	echo building
	$(MAKE) -f Makefile-javadoc alldocs

$(GH_PAGES)/index.html: $(GH_PAGES) build/site/index.html javadocs
	cd $(GH_PAGES) ; \
		rsync -vCra --delete --exclude=CNAME --exclude=.git ../build/site/ . ; \
		git add . ; \
		git status

push:
	cd $(GH_PAGES) ; \
		git commit -a -m "pushing docs updates" ; \
		git pull --rebase ; \
		git push ${REMOTE_REPO}

package-lock.json: package.json
	npm run clean-install

clean:
	rm -rf build antora-playbook.yml

mrclean: clean
	[ -e $(GH_PAGES) ] && rm -rf $(GH_PAGES) || true
	npm run clean

.PHONY: