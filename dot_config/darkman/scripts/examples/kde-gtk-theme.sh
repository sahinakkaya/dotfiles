#!/usr/bin/env bash

# GTK apps are not affected by the Plasma Global Theme, which only applies to Qt based programs.
# GTK themes can be installed here: Global Theme > Application Style > Configure GNOME/GTK Application Style.
# Reference: https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications

source "$HOME/scripts/common-vars.sh"
if [ $theme == "dark" ]; then
  theme_string="Breeze-dark-gtk"
else
  theme_string="Default"
fi

echo "string:$theme_string"

dbus-send --session --dest=org.kde.GtkConfig --type=method_call /GtkConfig org.kde.GtkConfig.setGtkTheme "string:$theme_string"
