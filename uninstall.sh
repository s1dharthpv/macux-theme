#!/usr/bin/env bash
# MacUX Theme — uninstaller

set -e

GTK_DIR="$HOME/.themes"
ICON_DIR="$HOME/.icons"

echo "Removing MacUX theme files..."
rm -rf "$GTK_DIR/MacUX" "$GTK_DIR/MacUX-Dark" "$GTK_DIR/MacUX-Light"
rm -rf "$ICON_DIR/MacUX-Icons" "$ICON_DIR/MacUX-Icons-Dark" "$ICON_DIR/MacUX-Cursors"

echo "Resetting to GNOME defaults..."
gsettings reset org.gnome.desktop.interface gtk-theme
gsettings reset org.gnome.desktop.interface icon-theme
gsettings reset org.gnome.desktop.interface cursor-theme
gsettings reset org.gnome.desktop.interface font-name
gsettings reset org.gnome.desktop.wm.preferences theme
gsettings reset org.gnome.desktop.wm.preferences button-layout

echo "Done. MacUX theme removed."
