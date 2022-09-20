MORPHIA_GITHUB=git@github.com:MorphiaOrg/morphia.git
GH_PAGES=gh_pages

default: site sync

$(GH_PAGES):
	git clone $(MORPHIA_GITHUB) -b gh-pages $(GH_PAGES) --depth 1

local-antora-playbook.yml: antora-playbook.yml Makefile
	@sed -e 's!^  - url: https://github.com/MorphiaOrg/\(.*\)!  - url: ../\1!' antora-playbook.yml > $@

package-lock.json: package.json
	npm run clean-install

local-site: local-antora-playbook.yml package-lock.json
	npm run local-build
	@touch build/site/.nojekyll

site: package-lock.json
	npm run build
	@touch build/site/.nojekyll

build/site/index.html: Makefile Makefile-javadoc
	$(MAKE) site
	$(MAKE) -f Makefile-javadoc alldocs

Makefile-javadoc: versions.list Makefile generate-makefile.sh
	@./generate-makefile.sh

javadocs: Makefile-javadoc
	@$(MAKE) -f Makefile-javadoc alldocs

$(GH_PAGES)/index.html: $(GH_PAGES) build/site/index.html javadocs
	cd $(GH_PAGES) ; \
		rsync -vCra --delete --exclude=CNAME --exclude=.git ../build/site/ . ; \
		git add . ; \
		git status

sync: $(GH_PAGES)/index.html

push:
	cd $(GH_PAGES) ; \
		git commit -a -m "pushing docs updates" ; \
		git pull --rebase ; \
		git push ${REMOTE_REPO}

publish: site sync push

clean:
	@rm -rf build local-antora-playbook.yml Makefile-javadoc

mrclean: clean
	@[ -e $(GH_PAGES) ] && rm -rf $(GH_PAGES) || true
	@npm run clean