#!/usr/bin/env bash
# MacUX Theme - uninstaller
# Reverts everything install.sh applied: theme/icon/cursor files, fonts,
# gsettings/dconf values, and the extensions it installed from EGO.
set -uo pipefail

GTK_THEME_NAME="WhiteSur-Dark-alt-blue"
ICON_THEME_NAME="WhiteSur-dark"
CURSOR_THEME_NAME="WhiteSur-cursors"

EGO_EXTENSIONS=(
  "dash2dock-lite@icedman.github.com"
  "quick-settings-tweaks@qwreey"
  "search-light@icedman.github.com"
  "CustomizeClockOnLockScreen@pratap.fastmail.fm"
  "blur-my-shell@aunetx"
  "compiz-alike-magic-lamp-effect@hermes83.github.com"
)

echo "Disabling and removing extensions fetched by install.sh..."
for uuid in "${EGO_EXTENSIONS[@]}"; do
  gnome-extensions disable "$uuid" 2>/dev/null || true
  gnome-extensions uninstall "$uuid" 2>/dev/null || true
done
echo "  (system-monitor / user-theme ship in Ubuntu's gnome-shell-extensions"
echo "   package and are left installed; disable them yourself if you don't want them)"

echo "Removing theme, icon, and cursor files..."
rm -rf "$HOME/.themes/WhiteSur"*
rm -rf "$HOME/.local/share/icons/WhiteSur"*
rm -rf "$HOME/.local/share/fonts/MacUX"

echo "Resetting desktop settings to GNOME defaults..."
gsettings reset org.gnome.desktop.interface gtk-theme
gsettings reset org.gnome.desktop.interface icon-theme
gsettings reset org.gnome.desktop.interface cursor-theme
gsettings reset org.gnome.desktop.interface font-name
gsettings reset org.gnome.desktop.interface document-font-name
gsettings reset org.gnome.desktop.interface monospace-font-name
gsettings reset org.gnome.desktop.interface color-scheme
gsettings reset org.gnome.desktop.interface clock-format
gsettings reset org.gnome.desktop.interface clock-show-seconds
gsettings reset org.gnome.desktop.interface clock-show-weekday
gsettings reset org.gnome.desktop.interface enable-animations
gsettings reset org.gnome.desktop.interface show-battery-percentage
gsettings reset org.gnome.desktop.wm.preferences theme
gsettings reset org.gnome.desktop.wm.preferences button-layout
gsettings reset org.gnome.desktop.wm.preferences titlebar-font
gsettings reset org.gnome.desktop.peripherals.touchpad natural-scroll
gsettings reset org.gnome.desktop.peripherals.touchpad tap-to-click
gsettings reset org.gnome.desktop.peripherals.pointingstick scroll-method
gsettings reset org.gnome.shell.extensions.user-theme name
gsettings reset org.gnome.shell enabled-extensions
gsettings reset org.gnome.shell disabled-extensions
gsettings reset org.gnome.shell favorite-apps

rm -f "$HOME/.config/gtk-3.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
fc-cache -f >/dev/null 2>&1 || true

echo "Done. MacUX theme removed. Log out and back in to fully reset the shell."
