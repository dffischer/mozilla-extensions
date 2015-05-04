# Mozilla Add-On Packages for AUR

This repository collects packages to globally install [add-ons](https://addons.mozilla.org/) for [Mozilla](https://www.mozilla.org/) software, such as [Firefox](https://www.mozilla.org/firefox/) and [Thunderbird](https://www.mozilla.org/thunderbird/), via [Arch Linux](http://archlinux.org/)'s [User Repository](https://aur.archlinux.org/). They are all built and installed in a similar way, so collecting them here eases maintenance. Code fragments are unified and shared among them via makepkg-templates. Purpose and effects of these are [described in their directory](makepkg-templates).

The [makepkg-template for git packages](https://github.com/dffischer/git-makepkg-template) are needed to expand some of the PKGBUILDs in this repository. [Install them globally](https://aur.archlinux.org/packages/git-makepkg-template-git/) or copy them into the [makepkg-templates directory](makepkg-templates) after cloning.


## Contributing

Contributions are very welcome. If you want to use the templates to package other extensions, feel free to fork this repository and add them. Pull requests are much appreciated.

Simple version updates do not necessarily need to be checked in. Please leave all templates unexpanded (as `template input` instead of `template begin` and `template and`) to avoid cluttered and redundant code. To ease your work, you may simply run [makepkg-expanded](https://github.com/dffischer/makepkg-expanded) over the packages herein, building them without expanding their templates. All files it produces are [automatically omitted from this repository](.gitignore).
