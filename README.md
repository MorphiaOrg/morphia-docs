# Morphia Documentation

This repository holds the source for the Morphia documentation.  It is built using [Hugo](https://gohugo.io) with the theme in
`themes/morphia`.  Each supported version of Morphia has its own section under `content/morphia/<version>`.  To build the docs you'll
need the following installed:

1.  hugo
1.  make
1.  jbang
1.  maven
1.  curl, jq, unzip, and rsync

## Building

To build all the docs, simply run `make` from the root directory.  This discovers the latest release of each documented version,
fetches the javadoc for each, pulls the benchmark history, and builds the site in to `build/site`.

To preview the docs while editing, run `make watch`.  This serves the site locally and rebuilds it as files change.

`make publish` synchronizes the built site in to a local checkout of the `gh-pages` branch and pushes it online.  It only publishes
from the `master` branch and requires commit rights.
