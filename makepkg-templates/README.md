# Templates for often used PKGBUILD snippets

As comments in the template code are not stripped when they are input, this file provides overview and documentation.

All templates end with a version number which should be increased on major changes. There always exists a symbolic link to the newest version, lacking any number.


## Retrieving and preparing sources and versions

- [source-xpi](source-xpi.template) downloads and extracts the latest version of a package and looks up the `$pkgver`.

  - The extension contents are placed unpacked in the `$srcdir`.

  - The latest version will always be fetched from [Mozilla's Add-On homepage](https://addons.mozilla.org/), though no checksums are provided for this file. The `PKGBUILD` should still include them in addition to the template.

  - The name of the add-on to download is automatically derived from the `$pkgname`, stripped from its first two words separated by dashes. The first word should always be the name of the program the add-on is for, e.g. _firefox_ or _thunderbird_, or _mozilla_ if it works with multiple of them. The second word should be _theme_ for graphical themes and _extension_ for any other add-on. This could be captured with a bash pattern by setting the _extglob_ shell option. As this would overly complicate the template and _shopt_ always comes with some caveats, the `PKGBUILD` author is expected to adhere to this simple guideline. If the name of the extension differs from this scheme, a variable `$_extname` may be set which will be used to compose the URL the extension is found at.

  - It always fetches a Linux version, if available, by requesting the adequate `platform:2` to the download URL.

  - The version is extracted from the file `install.rdf` which contains meta data included in the add-on.

  - Compatible target application versions can be retrieved from the addons.mozilla.org API description of the Add-On, which is downloaded as a source file, using [the function `query-version`](#user-content-needs-query-version). This is usually more up to date than the information included in the `install.rdf` file, especially when the Add-On was released before the current Firefox version.

  As this template uses [rdf-query](#user-content-rdf-query), [it should only be deployed at top level scope](#user-content-toplevel).

- [source-git-plain](source-git-plain.template) is an extension of the [git template](https://github.com/dffischer/git-makepkg-template/blob/master/git.template) augmenting it by a `prepare` function that will place the contents of the repository directly into `$srcdir`, omitting the `.git` directory, so that `package` functions can just install everything from there to the extension root directory.

  [A function `query-version`](#user-content-needs-query-version) is provided to retrieve information from the `install.rdf` file situated in the current working directory.

  For practical use, you may rather want to employ one of the two following variants that also automatically extract a package version.

- [source-git-rdf](source-git-rdf.template) further extends this with a `pkgver` function that extracts the version from an `install.rdf` file found in the repository root.

  As this template uses [rdf-query](#user-content-rdf-query), [it should only be deployed at top level scope](#user-content-toplevel).

- [source-git-json](source-git-json.template) looks for a `.json` file instead. Use this over the former for Add-Ons that generate the `install.rdf` using this JSON description.

All these templates starting in `source-` should provide a function `query-version`, so [the `targets` template](#user-content-needs-query-version) and everything built upon it can be utilized after including them.


# Package Composition

- [package-single](package-single.template) provides a `package` function installing everything found in the `$srcdir` into an extension directory, whose name is inferred from the `install.rdf` file found amongst there. The target application to install for is expected to be the first dash-separated word of the `$pkgname`.

  As this queries version information for the Add-On, [the remarks for the `targets` template](#user-content-needs-query-version) apply.

- [package-multi](package-multi.template) packages an Add-On that works with multiple applications. The name of the package is expected to start with _mozilla-_, the applications it works with are expected as `$optdepends`.

  Everything found in the `$srcdir` is first installed to a common extension directory. Then, symbolic links pointing there are placed in the directories the respective target applications expect extensions to be installed to. These symlinks are complied as dedicated split packages, their name generated from the original `$pkgname` replacing the starting _mozilla_ with the target application name. Replacing the original `$optdepends` by split packages all interrelated is necessary to correctly track the dependent versions as Pacman as of [bug 44957](https://bugs.archlinux.org/index.php?do=details&task_id=44957) currently does not look at the version restriction of optional dependencies.

  As this queries version information for the Add-On, [the remarks for the `targets` template](#user-content-needs-query-version) apply.

- <a name="prepare-target" href="prepare-target.template">prepare-target</a> provides a function `prepare_target` that composes the two variables

  - denoting the extension `$id`, which is also the name of the diretory to install the extension to, and

  - the `$destdir` directory where this extension root directory should be placed.

  It also ensures the existance of `$destdir`, but leaves `$destdir/$id` for the user to create as a directory or link.

  To do so, it needs the extensions `install.rdf` present in the current working directory. Which application to target is determined from the first dash separated word of the current `$pkgname`. This variable is assumed to be a scalar, meaning the fragment should only be used in `package` functions when a split package is build and `$pkgname` thus is an array outside their scope.

  As this template uses [rdf-query](#user-content-rdf-query), [it should only be deployed at top level scope](#user-content-toplevel).

- [install-all](install-all.template) installs everything found in the current working directory, including hidden files, to `$destdir/$id`. As this may have made you guess, it depends on these variables to be initialized through [the prepare-target template](#user-content-prepare-target) beforehand.

- [targets](targets.template) contains functions to collect information about target applications.

  - <a name="emid">`emid`</a> accepts an application name as only argument and turns it into the corresponding identifier that is used to denote this applicaiton within an `<em:id>` tag.

  - `version` extracts the boundaries of supported versions. To do so, it needs two arguments:

    - `min` or `max` to determine wether to extract the minimum or maximum compatible version, respectively and

    - the target application `em:id` most likely obtained by quering [the `emid` function](#user-content-emid).

  - `version-range` needs the application name as only argument and returns package relation specifiers to restrict the target application version suited to place into `PKGBUILD` arrays like `$depends`. It will return two array elements, so when used with command substituation, do not place the results in quotes.

  <a name="needs-query-version">To use the functions of this template, a function `query-version` should be defined, which takes the same arguments as the `version` function and outputs a version string as found in the `install.rdf` file of an Add-On. Its output may contain the wildcard `*`. All [templates named starting in `source-`](#retrieving-and-preparing-sources-and-versions) provide such a function.</a>

  As this template uses [rdf-query](#user-content-rdf-query), [it should only be deployed at top level scope](#user-content-toplevel).


# Various Helpers

- <a name="rdf-query" href="rdf-query.template">rdf-query</a> contains a function `sparql` to query the _install.rdf_ files. Its first argument is the WHERE part of a SPARQL query, without braces. The `em:` prefix as defined in Mozilla's _install.rdf_ is readily available to use in there. The second argument should be the file to run the query on, if it differs from _install.rdf_. It will return one valid assignment for the variable `?x` from the query.

  <a name="toplevel">This template should never be included inside function scope, as it has to add to the `$makedepends` array. It is used as a sort of library function by many of the other templates.</a>

- [github](github.template) contains a notice to this repositories location as a comment, where all the PKGBUILDs are maintained. It is intended to be placed directly under the list of maintainer and contributors to the PKGBUILD.
