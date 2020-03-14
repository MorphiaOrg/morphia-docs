# Morphia Documentation
 
This repository holds the source for the Morphia documentation.  It is currently broken up in to two main sections:  `landing` and
 `reference`.  `landing` holds the main page which links off to the versioned docs.  `reference` holds the guides specific to each
  supported version of Morphia.  To build the docs you'll need the following installed:

1.  Java 11+
1.  Maven 3.6.3+
1.  Hugo 0.62+
1.  make

## Building

To build all the docs, simply run `make` from the root directory.  If you're updating a specific version's documentation, running `make
` in that version's folder will build the subset of the docs for that version.  Whether working on `landing` or a `reference` version you
 can track the live changes using `make watch`.  This is simply a wrapper via the `Makefile` over the `hugo watch` command.
 

