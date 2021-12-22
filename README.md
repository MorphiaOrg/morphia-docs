# Morphia Documentation
 
This repository holds the source for the Morphia documentation.  It is built using [antora](antora.org) to build and aggregate the documentation for the supported versions of Morphia. To build the docs you'll need the following installed:

1.  npm
1.  make

## Building

To build all the docs, simply run `make` from the root directory.  This will build the site locally and synchronize it in to a local 
checkout of the `gh_pages` branch where you can view the documentation as it would look online.  If you have commit rights, `make 
publish` will do all that and push those updates online.
 

