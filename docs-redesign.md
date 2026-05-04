## Overview

* The new docs site will be based on Hugo.
* All implementation work will be done in the branch.
* The 1.6.x branch will not be carried forward into the new site.

## Content

* Versioned content lives permanently in this repo under `content/` — `master`, `2.5.x`, and `2.4.x`. It is no longer sourced from the morphia source branches.
* URL redirects are in place where paths changed from the old Antora site.
* Shared/included files are referenced dynamically via a Hugo shortcode rather than inlined.
* Code block callout markers stay as plain comments (e.g., `// <1>`); the annotations below use a `callout-item` shortcode.
* Critter is integrated into Morphia proper — it is not referenced as a separate project.
* The `master` branch represents the snapshot version. Its version label in the selector is `master`; its URL uses the major.minor form so the URL does not change on release. All other versions render as major.minor only.

## Hugo Structure & Configuration

* A Hugo configuration will be generated to support the new structure and design.
* The navigation structure will be recreated in Hugo to match the current structure as closely as possible.
* The Hugo theme will match the new home/landing page design to ensure a consistent look and feel across the entire site.
* All versioned content lives under a single source tree and is included in a single Hugo build. Content for each version resides in its own folder under `content/` (named for the branch it represents), and Hugo produces the full multi-version site in one pass.

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

