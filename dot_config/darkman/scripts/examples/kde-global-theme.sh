#!/usr/bin/env bash

# Change the global Plasma Theme. On Manjaro you can use "org.manjaro.breath-dark.desktop" 
# or you can create your own global Plasma Theme with the "Plasma Look And Feel Explorer".
# Reference: https://userbase.kde.org/Plasma/Create_a_Global_Theme_Package
#
# Since Plasma 5.26 the lookandfeeltool does not work anymore without "faking" the screen.
# Reference: https://bugs.kde.org/show_bug.cgi?id=460643

lookandfeeltool -platform offscreen --apply "org.kde.breeze.desktop"
# lookandfeeltool -platform offscreen --apply "org.kde.breezetwilight.desktop"
# lookandfeeltool -platform offscreen --apply "org.kde.breezedark.desktop"
