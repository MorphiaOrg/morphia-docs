MORPHIA_GITHUB=git@github.com:MorphiaOrg/morphia.git
MORPHIA_DEV=2.2.0-SNAPSHOT
GH_PAGES=gh_pages

$(GH_PAGES):
	git clone $(MORPHIA_GITHUB) -b gh-pages $(GH_PAGES) --depth 1

local-antora-playbook.yml: antora-playbook.yml Makefile
	@sed -e 's!^  - url: https://github.com/MorphiaOrg/\(.*\)!  - url: ../\1 !' antora-playbook.yml > $@

package-lock.json: package.json
	npm run clean-install

local-site: package-lock.json local-antora-playbook.yml
	npm run local-build
	@touch build/site/.nojekyll

site: package-lock.json
	npm run build
	@touch build/site/.nojekyll

build/site/index.html:
	$(MAKE) site

$(GH_PAGES)/index.html: $(GH_PAGES) build/site/index.html
	rsync -Cra --delete --exclude=CNAME build/site/ $(GH_PAGES)/
	cd $(GH_PAGES) ; touch hi ; git add hi
	cd $(GH_PAGES) ; git status ; git add .
	pwd ; ls gh_pages/morphia/2.2
	pwd ; ls build/site/morphia/2.2

sync: $(GH_PAGES)/index.html

push:
	cd $(GH_PAGES) ; \
		git commit -a -m "pushing docs updates" ; \
		git status
		# git push ${REMOTE_REPO} ; \

publish: site sync push

clean:
	@rm -rf build dev.javadoc.jar local-antora-playbook.yml
