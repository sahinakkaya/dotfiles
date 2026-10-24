#!/bin/bash

set -eufo pipefail

# Enable tap to click for built-in and Bluetooth trackpads.
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1

# Disable swipe gestures for back/forward navigation in supporting apps.
# defaults write -g AppleEnableSwipeNavigateWithScrolls -int 0

# Repeat held letters instead of displaying the accented-character picker.
# defaults write -g ApplePressAndHoldEnabled -int 0

# Show all filename extensions in Finder.
defaults write -g AppleShowAllExtensions -int 1


# Enlarge the pointer when shaking the mouse to locate it (0 enables this).
# defaults write -g CGDisableCursorLocationMagnification -int 0

# Delay before a held key starts repeating; lower values start sooner.
defaults write -g InitialKeyRepeat -int 12

# Key repeat interval; lower values repeat faster.
defaults write -g KeyRepeat -int 2

# Disable automatic capitalization.
defaults write -g NSAutomaticCapitalizationEnabled -int 0

# Disable converting typed hyphens into typographic dashes.
# defaults write -g NSAutomaticDashSubstitutionEnabled -int 0

# Disable inline predictive text suggestions.
defaults write -g NSAutomaticInlinePredictionEnabled -int 0

# Disable inserting a period when typing two spaces.
# defaults write -g NSAutomaticPeriodSubstitutionEnabled -int 0

# Disable smart quotes; keep straight quotes.
defaults write -g NSAutomaticQuoteSubstitutionEnabled -int 0

# Disable automatic spelling correction (not necessarily spelling underlines).
defaults write -g NSAutomaticSpellingCorrectionEnabled -int 0

# Disable additional automatic text correction; support varies by app/version.
defaults write -g NSAutomaticTextCorrectionEnabled -int 0

# Disable some automatic window animations in supporting apps.
# idk what this does, let see if i notice a change
# yeap, i notice change. it should be left as enabled (which is default i guess)
defaults write -g NSAutomaticWindowAnimationsEnabled -int 1

# Default to local storage instead of iCloud for new documents in supporting apps.
defaults write -g NSDocumentSaveNewDocumentsToCloud -int 0

# Hide action images in supporting menus (poorly documented; test before use).
# defaults write -g NSMenuEnableActionImages -int 0

# Clear the text-replacement list. This can remove existing replacements.
# defaults write -g NSUserDictionaryReplacementItems '()'

# Disable automatic spelling correction in supporting WebKit text fields.
# defaults write -g WebAutomaticSpellingCorrectionEnabled -int 0

# Use F1-F12 as standard function keys; hold Fn for brightness, volume, etc.
# defaults write -g com.apple.keyboard.fnState -int 1

# Disable natural scrolling.
# defaults write -g com.apple.swipescrolldirection -int 0

# Disable Force Click (support for this global key varies by macOS version).
# defaults write -g com.apple.trackpad.forceClick -int 0

# Automatically hide the Dock.
defaults write com.apple.dock autohide -int 1


# Hide the recent-apps section of the Dock; pinned and running apps remain.
defaults write com.apple.dock show-recents -int 0

# Disable the trackpad gesture for showing the desktop.
# defaults write com.apple.dock showDesktopGestureEnabled -int 0

# Disable the trackpad gesture for Launchpad on macOS versions that provide it.
# defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

# Disable the trackpad gesture for Mission Control.
# defaults write com.apple.dock showMissionControlGestureEnabled -int 0

# Show the full folder path in Finder's window title.
defaults write com.apple.finder _FXShowPosixPathInTitle -int 1

# Prefer List view in Finder; folders may retain their saved views.
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv

# Keep folders above files when sorting by name in Finder.
defaults write com.apple.finder _FXSortFoldersFirst -int 1

# Automatically remove items that have been in Trash for more than 30 days.
defaults write com.apple.finder FXRemoveOldTrashItems -int 1

# Disable the warning when changing a filename extension.
defaults write com.apple.finder FXEnableExtensionChangeWarning -int 0
