Notes for developers.

### Generating a new release:

* Check that all issues for the release milestone are closed.
* Update the ChangeLog with the date and list of changes for the new release.
* Update/check the $VERSION number in bin/circleator.
* Update README.md and, documentation as needed
* Check that prerequisites are consistent between README.md and INSTALL (in master), 
  and install.md (in gh-pages)
* Commit any changes.
* Run the regression tests (./Build test at the top-level)
* Go to https://github.com/jonathancrabtree/Circleator/releases
* Click on "Draft a new release"
* Enter the release tag and name so that they match the format of the previous ones.
* Copy the relevant ChangeLog entry into the "Describe this release" box.
* Check "This is a pre-release" if this is a release candidate (i.e. version number ends in rc1, rc2, etc.)
* Click on "Publish release"
* Download the zip or tar file from the GitHub releases page
* Install and test it according to the INSTALL documentation.
* Announce the new release on the Circleator Google Group.


