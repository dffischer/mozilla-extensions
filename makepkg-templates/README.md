# Templates for often used PKGBUILD snippets

As comments in the template code are not stripped when they are input, this file provides overview and documentation.

All templates end with a version number which should be increased on major changes. There always exists a symbolic link to the newest version, lacking any number.

- [source-xpi](source-xpi.template) downloads and extracts the latest version of a package and looks up the `$pkgver`.

  - The extension contents are placed unpacked in the `$srcdir`.

  - The latest version will always be fetched from [Mozilla's Add-On homepage](https://addons.mozilla.org/), though no checksums are provided for this file. The `PKGBUILD` should still include them in addition to the template.

  - The name of the add-on to download is always the `$pkgname`, stripped from its first two words separated by dashes. The first word should always be the name of the program the add-on is for, e.g. _firefox_ or _thunderbird_, or _mozilla_ if it works with multiple of them. The second word should be _theme_ for graphical themes and _extension_ for any other add-on. This could be captured with a bash pattern by setting the _extglob_ shell option. As this would overly complicate the template and _shopt_ always comes with some caveats, the `PKGBUILD` author is expected to adhere to this simple guideline.

  - It always fetches a Linux version, if available, by requesting the adequate `platform:2` to the download URL.

  - The version is extracted from the file `install.rdf` which contains meta data included in the add-on.

- [git-install-rdf](git-install-rdf.template) is an extension of the [git template](https://github.com/dffischer/git-makepkg-template/blob/master/git.template) that generates a `$pkgver` from an `install.rdf` file found in the repository root. The `install.rdf` or the version string therein are also sometimes generated from a `.json` file. If such is present, it is used instead.

- [install-rdf-version](install-rdf-version.template) contains just the single line to extract the version from an `install.rdf` file. It is used in the former two templates.

- [package](package.template) provides a `package` function installing everything found in the `$srcdir` into an extension directory, which name is inferred from the `install.rdf` file found amongst there. The target application to install for is expected to be the first dash-separated word of the `$pkgname`.
