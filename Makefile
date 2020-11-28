MORPHIA_GITHUB=git@github.com:MorphiaOrg/morphia.git
MORPHIA_DEV=2.2.0-SNAPSHOT
GH_PAGES=gh_pages

$(GH_PAGES):
	git clone $(MORPHIA_GITHUB) -b gh-pages $(GH_PAGES)

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

publish: $(GH_PAGES) site
	cd $(GH_PAGES) ; [ "git status -s -uno" ] && ( git checkout . ; git pull --rebase )
	rsync -Cra --delete --exclude=CNAME build/site/ $(GH_PAGES)/
	cd $(GH_PAGES) ; ( git add . ; git commit -a -m "pushing docs updates" ; git push )

clean:
	@rm -rf build dev.javadoc.jar $(GH_PAGES) local-antora-playbook.yml