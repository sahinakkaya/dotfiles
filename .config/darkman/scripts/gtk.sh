#!/usr/bin/env bash

theme=$(darkman get)
gsettings set org.gnome.desktop.interface color-scheme "prefer-$theme"
