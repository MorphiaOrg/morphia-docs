MORPHIA_GITHUB=git@github.com:MorphiaOrg/morphia.git
MORPHIA_DEV=2.2.0-SNAPSHOT
GH_PAGES=gh_pages

$(GH_PAGES):
	git clone $(MORPHIA_GITHUB) -b gh-pages $(GH_PAGES)

local-antora-playbook.yml: antora-playbook.yml
	sed -e 's|https://github.com/MorphiaOrg/|../|' antora-playbook.yml > $@

package-lock.json: package.json
	npm run clean-install

local-site: package-lock.json local-antora-playbook.yml dev.javadoc.jar
	npm run local-build
	touch build/site/.nojekyll

site: package-lock.json dev.javadoc.jar
	npm run build
	touch build/site/.nojekyll

publish: $(GH_PAGES) site
	cd $(GH_PAGES) ; [ "git status -s -uno" ] && ( git checkout . ; git pull --rebase )
	rsync -Crav --delete build/site/ $(GH_PAGES)/
	cd $(GH_PAGES) ; sh ../bin/pushGhPages.sh

dev.javadoc.jar:
	mvn -U org.apache.maven.plugins:maven-dependency-plugin:get \
    	-Dartifact=dev.morphia.morphia:morphia-core:$(MORPHIA_DEV):jar:javadoc \
		-DremoteRepositories=https://oss.sonatype.org/content/repositories/snapshots
	cp ~/.m2/repository/dev/morphia/morphia/morphia-core/$(MORPHIA_DEV)/morphia-core-$(MORPHIA_DEV)-javadoc.jar $@

clean:
	@rm -rf build dev.javadoc.jar $(GH_PAGES) local-antora-playbook.yml