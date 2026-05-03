* the new docs design will be based on hugo.
* all work will be done in a worktree.
* the initial seed for this new work will take the docs/ folder from the master, 2.5.x, and 2.4.x and copy them into a new hugo subfolder.  The 1.6.x branch will not be part of this conversion.
  * these folders will be the eventual source of truth for each version.  the docs will be ultimately removed from their source branches and maintained here. 
    * in the event of url changes, redirects will be put in place to ensure that existing links continue to work.
  * this seed will be converted from the antora/asciidoc format to the hugo/markdown format.
  * a hugo configuration will be generated to support the new structure and design.
  * the navigation structure will be recreated in hugo to match as closely as possible the current structure.
  * any partials will be converted to hugo shortcodes.  variants might be necessary to handle the different versions but this should be minimized as much as possible and eliminated altogether if possible.
  * assets will be moved to a hugo appropriate location and referenced from the markdown files as needed.
  * the language and tone of the docs should be normalized across versions with the master docs serving as the model for earlier versions.  the goal is to have a consistent voice and style across all versions of the documentation.
  * critter will no longer be referenced as a separate project since it has been integrated in to morphia proper.  any references to critter in the older docs should be updated to reflect this change.
* the hugo generation will be driven by a makefile as well:
  * the makefile should be modeled after what is currently in the root but updated as appropriate for the new design and structure.
  * the branch processing will be driven by the presence of folders in the branches/ directory. each folder will be named for the branch it represents and contain the content for that branch.
  * the makefile will contain a target to download and synchronize the javadoc for each version in a subtree for each version.
    * this subtree will not be committed since it is generated but should be present for the ultimate bundling of the generated content into its final form for publishing to gh_pages.
  * the local target will not be necessary since all docs are now maintained locally instead of remote repos.
* A design for the home/landing page is being done on claude design and should be incorporated once that design is finalized.
  * The new site will have a version selector that allows users to switch between the different versions of the documentation. This will be implemented using JavaScript and will dynamically load the appropriate content based on the user's selection.
    * the version selector will update to the version of the page being viewed.
    * a 404 redirector will be implemented to handle cases where a user tries to access a page that does not exist in the selected version. In this case, the user will be redirected to the version index page for the selected version, which will list all available pages for that version and allow the user to navigate to the desired content.
  * if possible, the hugo theme will match the new design for the home/landing page to ensure a consistent look and feel across the entire site.
* The new site will be deployed to GitHub Pages using the gh-pages branch, and the deployment process will be automated using GitHub Actions to ensure that the latest documentation is always available online.