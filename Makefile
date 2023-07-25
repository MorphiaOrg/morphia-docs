MORPHIA_GITHUB=git@github.com:MorphiaOrg/morphia.git
GH_PAGES=gh_pages
BRANCHES=master 2.4.x 2.3.x 2.2.x 2.1.x 1.6.x
PLAYBOOK=antora-playbook.yml

default: site sync

$(GH_PAGES):
	git clone $(MORPHIA_GITHUB) -b gh-pages $(GH_PAGES) --depth 1

build/morphia: .PHONY
	[ ! -d build/morphia ] && git clone $(MORPHIA_GITHUB) build/morphia || true
	cd build/morphia && git pull --all

versions.list: Makefile
	> versions.list
	@for BRANCH in $(BRANCHES); \
	do \
	  cd build/morphia ; git checkout $$BRANCH; cd - ;\
	  make -s -B build/majorVersion ; \
      cat build/fullVersion >> $@; \
	done;
	cd build/morphia ; git checkout master; cd - ;\


local: .PHONY
	@$(eval PLAYBOOK=local-${PLAYBOOK} )

build/majorVersion: build/morphia/pom.xml
	bin/extractVersions.sh

home/modules/ROOT/pages/index.html : Makefile versions.list Makefile-javadoc
	@make -s build/morphia
	@cd build/morphia ; git checkout ` echo $(BRANCHES) | cut -d' ' -f 2`
	@make -s build/majorVersion
	@sed -i $@ -e "s|../morphia/.*/index.html|../morphia/`cat build/majorVersion`.`cat build/minorVersion`/index.html|"

antora-playbook.yml: Makefile .PHONY
	sed antora-playbook-template.yml \
		-e "s/branches: \[.*\] ### morphia branches/branches: [ `echo $(BRANCHES) | sed -e 's/ /, /g'` ] ### morphia branches/" > $@

local-antora-playbook.yml: antora-playbook.yml Makefile
	@sed -i -e 's!^  - url: https://github.com/MorphiaOrg/\(.*\)!  - url: ../\1!' antora-playbook.yml

site: home/modules/ROOT/pages/index.html package-lock.json
	@make -s $(PLAYBOOK)
	@npm run build
	@touch build/site/.nojekyll
	@cp home/modules/ROOT/pages/*.html build/site/landing

sync: $(GH_PAGES)/index.html

publish: site sync push

Makefile-javadoc: versions.list Makefile generate-makefile.sh
	@bash ./generate-makefile.sh

javadocs: Makefile Makefile-javadoc
	@echo building
	@$(MAKE) -f Makefile-javadoc alldocs

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
	@rm -rf build antora-playbook.yml Makefile-javadoc

mrclean: clean
	@[ -e $(GH_PAGES) ] && rm -rf $(GH_PAGES) || true
	@npm run clean

.PHONY: