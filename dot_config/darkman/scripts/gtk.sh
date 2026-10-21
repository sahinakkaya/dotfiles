#!/usr/bin/env bash

theme=$1
gsettings set org.gnome.desktop.interface color-scheme "prefer-$theme"


if [ "$theme" == "dark" ]; then
  QT_QPA_PLATFORM=offscreen plasma-apply-colorscheme BreezeDark
else
  QT_QPA_PLATFORM=offscreen plasma-apply-colorscheme BreezeLight
fi
