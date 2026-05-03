## Overview

* The new docs site will be based on Hugo.
* All implementation work will be done in the branch.
* The 1.6.x branch will not be carried forward into the new site.

## Content Migration

* The initial seed will copy the `docs/` folder from the `master`, `2.5.x`, and `2.4.x` branches into a new Hugo subfolder.
  * These folders become the permanent source of truth for each version. Docs will be removed from their source branches and maintained here going forward.
  * In the event of URL changes, redirects will be put in place to ensure existing links continue to work.
* Content will be converted from the Antora/AsciiDoc format to Hugo/Markdown.
  * Any partials will be converted to Hugo shortcodes. Version-specific variants may be necessary but should be minimized and eliminated where possible.
  * Included files (e.g., config snippets referenced via `include::example$file[]`) will remain as separate files and be dynamically included from their source locations via a Hugo shortcode.
  * Code block callout annotations (`// <1>`) will be converted to Hugo shortcodes. Markers inside code blocks remain as plain comments (e.g., `// <1>`); the corresponding annotations below the block use a `callout-item` shortcode.
  * Assets will be moved to a Hugo-appropriate location and referenced from the Markdown files as needed.
* Critter will no longer be referenced as a separate project since it has been integrated into Morphia proper. Any references to Critter in the older docs should be updated to reflect this.
* The language and tone of the docs should be normalized across versions, with the `master` docs serving as the model for earlier 
  versions. The goal is a consistent voice and style across all versions.  You will perform this normalization as part of the content migration, ensuring that all versions reflect the same level of clarity and professionalism.
* For the snapshot version (only supported from master.  all other branches should render as major.minor), the version should display as 
  'master' and the url should still be major.minor so that when master is released, the url will not change.  The version selector should also reflect this by showing 'master' as the label for the snapshot version.

## Hugo Structure & Configuration

* A Hugo configuration will be generated to support the new structure and design.
* The navigation structure will be recreated in Hugo to match the current structure as closely as possible.
* The Hugo theme will match the new home/landing page design to ensure a consistent look and feel across the entire site.
* Branch content will be driven by the presence of folders in the `branches/` directory. Each folder will be named for the branch it represents and contain the content for that branch.

## Build System

* Hugo generation will be driven by a Makefile modeled after the current root Makefile, updated as appropriate for the new design.
* The Makefile will contain a target to download and synchronize the Javadoc for each version.
  * The Javadoc subtree will not be committed since it is generated, but must be present for the final bundling of content before 
    publishing to `gh-pages`.  the javadoc will live in a javadoc/ folder under its respective version folder (e.g., `build/site/morphia/2.4/javadoc/`).
* A `local` target is not necessary since all docs are now maintained locally rather than pulled from remote repos.

## Site Design

* The site will have a version selector that allows users to switch between documentation versions.
  * The selector will reflect the version of the page currently being viewed.
  * A 404 handler will redirect users who access a page that does not exist in the selected version to the version's index page, where they can navigate to the desired content.

## Deployment

* The site will be deployed to GitHub Pages via the `gh-pages` branch.
* The deployment process will be automated using GitHub Actions to ensure the latest documentation is always available.
* the existing workflow will updated to use the new hugo set up.
* The workflow will continue to use the `GH_PUSH_TOKEN` secret for authentication when pushing to the `gh-pages` branch, ensuring a secure and seamless deployment process.

## Theme & Visual Design

The landing page and site theme is based on the design at `morphia-website/project/b-editorial.html`. Key design tokens:

* **Colors:** warm parchment background (`#f6f3ec`), deep teal accent (`oklch(0.45 0.07 195)`), burnt amber accent (`oklch(0.55 0.12 60)`), warm near-black ink (`#14110d`)
* **Typography:** `Geist` (sans/body), `Instrument Serif` (display headings, italic), `JetBrains Mono` (code, labels, version numbers)
* **Logo:** custom SVG in teal/amber
* **Nav:** sticky with blur backdrop; version selector dropdown uses monospace font with amber dot indicator and "latest" pill
* **Sections:** hero with animated Java↔BSON morph figure, pull-quote/concept block, 3-column feature grid (paper cards), code snippet pairs, quickstart CTA, footer
* **Texture:** subtle dot-grid overlay on the parchment background (CSS radial-gradient)

