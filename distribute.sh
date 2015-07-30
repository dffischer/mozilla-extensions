#!/bin/bash

exec makepkg-expanded -r 'exec aurbranch -p "$1" "${@/%/:}"' -a
