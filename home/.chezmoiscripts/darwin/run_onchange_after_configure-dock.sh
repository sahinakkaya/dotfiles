#!/bin/bash

set -eufo pipefail

trap 'killall Dock' EXIT

declare -a remove_labels=(
	Launchpad
	Safari
	Messages
	Maps
	Photos
	FaceTime
  Phone
	Calendar
	Contacts
	Notes
	Freeform
	TV
	Music
	Keynote
	Numbers
	Pages
  Games
	"App Store"
)

for label in "${remove_labels[@]}"; do
	dockutil --no-restart --remove "${label}" || true
done
