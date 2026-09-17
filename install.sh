#!/usr/bin/env bash
# MacUX Theme - one-command installer
# Reproduces one exact desktop: WhiteSur GTK/shell theme (Dark, alt window
# controls, blue accent), WhiteSur icons + cursors, SF Pro / Source Code Pro
# fonts, 8 GNOME Shell extensions with their settings, plus the stock Ubuntu
# extensions/dock this profile turns off, on Ubuntu 24.04 / GNOME Shell 46.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DCONF_DIR="$SCRIPT_DIR/dconf"

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[0;33m'; RESET='\033[0m'
info() { echo -e "${CYAN}> $*${RESET}"; }
ok()   { echo -e "${GREEN}OK $*${RESET}"; }
warn() { echo -e "${YELLOW}! $*${RESET}"; }

# -- Fixed target names (what this script reproduces) -------------------------
GTK_THEME_NAME="WhiteSur-Dark-alt-blue"      # WhiteSur-gtk-theme --color dark --alt alt --theme blue
ICON_THEME_NAME="WhiteSur-dark"              # WhiteSur-icon-theme (default variant, dark active)
CURSOR_THEME_NAME="WhiteSur-cursors"         # WhiteSur-cursors (no flags)

SHELL_VERSION="$(gnome-shell --version 2>/dev/null | grep -oE '[0-9]+' | head -1 || echo 46)"

# Extensions this profile enables. Two ship in Ubuntu's gnome-shell-extensions
# package; the rest are fetched from extensions.gnome.org at install time.
EGO_EXTENSIONS=(
  "dash2dock-lite@icedman.github.com:dash2dock-lite"
  "quick-settings-tweaks@qwreey:quick-settings-tweaks"
  "search-light@icedman.github.com:search-light"
  "CustomizeClockOnLockScreen@pratap.fastmail.fm:customize-clock-on-lockscreen"
  "blur-my-shell@aunetx:blur-my-shell"
  "compiz-alike-magic-lamp-effect@hermes83.github.com:magic-lamp"
)
PACKAGED_EXTENSIONS=(
  "system-monitor@gnome-shell-extensions.gcampax.github.com:system-monitor"
  "user-theme@gnome-shell-extensions.gcampax.github.com:"
)

# Stock Ubuntu/GNOME extensions this profile turns off (dash2dock-lite
# replaces the dock, so ubuntu-dock/ding double up otherwise).
STOCK_EXTENSIONS_TO_DISABLE=(
  "ding@rastersoft.com"
  "tiling-assistant@ubuntu.com"
  "ubuntu-appindicators@ubuntu.com"
  "ubuntu-dock@ubuntu.com"
  "apps-menu@gnome-shell-extensions.gcampax.github.com"
  "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
  "drive-menu@gnome-shell-extensions.gcampax.github.com"
  "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
  "light-style@gnome-shell-extensions.gcampax.github.com"
  "native-window-placement@gnome-shell-extensions.gcampax.github.com"
  "places-menu@gnome-shell-extensions.gcampax.github.com"
  "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com"
  "window-list@gnome-shell-extensions.gcampax.github.com"
  "windowsNavigator@gnome-shell-extensions.gcampax.github.com"
  "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
)

# -- 0. Preflight --------------------------------------------------------------
if ! grep -qi "ubuntu" /etc/os-release 2>/dev/null; then
  warn "This installer targets Ubuntu 24.04 / GNOME Shell 46. Continuing anyway..."
fi

info "Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y -qq git curl jq unzip dconf-cli fontconfig sassc gnome-shell-extensions >/dev/null
ok "Dependencies installed"

info "Fetching theme submodules..."
git -C "$SCRIPT_DIR" submodule update --init --recursive --depth 1
ok "Submodules ready"

# -- 1. Fonts (SF Pro + Source Code Pro) ---------------------------------------
# SF Pro is Apple-proprietary and not redistributed in this repo; it's pulled
# from a well-known community mirror at install time. Source Code Pro is
# Adobe's official open-source (OFL) release.
info "Installing fonts..."
FONT_DIR="$HOME/.local/share/fonts/MacUX"
mkdir -p "$FONT_DIR"
TMP_FONTS="$(mktemp -d)"
trap 'rm -rf "$TMP_FONTS"' EXIT

git clone --depth 1 https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts.git "$TMP_FONTS/sf-pro" >/dev/null 2>&1
cp "$TMP_FONTS/sf-pro"/*.otf "$FONT_DIR/"

git clone --depth 1 --filter=blob:none --sparse https://github.com/adobe-fonts/source-code-pro.git "$TMP_FONTS/scp" >/dev/null 2>&1
git -C "$TMP_FONTS/scp" sparse-checkout set OTF >/dev/null 2>&1
cp "$TMP_FONTS/scp/OTF"/SourceCodePro-{Regular,Medium,Bold,It}.otf "$FONT_DIR/"

fc-cache -f "$FONT_DIR" >/dev/null
ok "Fonts installed -> $FONT_DIR"

# -- 2. GTK theme ---------------------------------------------------------------
info "Installing GTK theme..."
bash "$SCRIPT_DIR/WhiteSur-gtk-theme/install.sh" \
    --color dark \
    --alt alt \
    --theme blue \
    --opacity normal \
    --libadwaita \
    --dest "$HOME/.themes"
ok "GTK theme installed -> ~/.themes/${GTK_THEME_NAME}"

# -- 3. Icons ---------------------------------------------------------------------
info "Installing icons..."
bash "$SCRIPT_DIR/WhiteSur-icon-theme/install.sh" \
    --dest "$HOME/.local/share/icons"
ok "Icons installed -> ~/.local/share/icons/${ICON_THEME_NAME}"

# -- 4. Cursors -------------------------------------------------------------------
info "Installing cursors..."
bash "$SCRIPT_DIR/WhiteSur-cursors/install.sh"
ok "Cursors installed -> ~/.local/share/icons/${CURSOR_THEME_NAME}"

# -- 5. Core desktop settings -------------------------------------------------------
# dconf load replaces the ENTIRE target path with only what's in the file, so
# it must run before the gsettings calls that follow, not after - otherwise it
# would wipe the theme/font keys those calls just set.
info "Applying interface, window-manager, and peripheral settings..."
dconf load /org/gnome/desktop/interface/       < "$DCONF_DIR/interface.ini"
dconf load /org/gnome/desktop/wm/preferences/  < "$DCONF_DIR/wm-preferences.ini"
dconf load /org/gnome/desktop/peripherals/     < "$DCONF_DIR/peripherals.ini"

gsettings set org.gnome.desktop.interface gtk-theme    "$GTK_THEME_NAME"
gsettings set org.gnome.desktop.interface icon-theme   "$ICON_THEME_NAME"
gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME_NAME"
gsettings set org.gnome.desktop.interface font-name             "SF Pro Text 11"
gsettings set org.gnome.desktop.interface document-font-name    "SF Pro Text 11"
gsettings set org.gnome.desktop.interface monospace-font-name   "Source Code Pro 11"
gsettings set org.gnome.desktop.wm.preferences titlebar-font    "SF Pro Display Semibold 11"

# GTK apps that don't go through gsettings (some Flatpaks, non-GNOME toolkits)
# read these files directly.
for ver in 3.0 4.0; do
  mkdir -p "$HOME/.config/gtk-$ver"
  cat > "$HOME/.config/gtk-$ver/settings.ini" <<EOF
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=$GTK_THEME_NAME
gtk-icon-theme-name=$ICON_THEME_NAME
gtk-cursor-theme-name=$CURSOR_THEME_NAME
gtk-font-name=SF Pro Text 11
EOF
done
ok "Desktop settings applied"

# -- 6. GNOME Shell extensions ------------------------------------------------------
install_ego_extension() {
  local uuid="$1"
  info "  fetching ${uuid}..."
  local info_json pk zip
  info_json="$(curl -fsSL "https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=${SHELL_VERSION}")"
  pk="$(echo "$info_json" | jq -r --arg v "$SHELL_VERSION" '.shell_version_map[$v].pk // empty')"
  if [ -z "$pk" ]; then
    warn "  no build of ${uuid} for GNOME Shell ${SHELL_VERSION}; skipping"
    return 1
  fi
  zip="$(mktemp --suffix=.zip)"
  curl -fsSL "https://extensions.gnome.org/download-extension/${uuid}.shell-extension.zip?version_tag=${pk}" -o "$zip"
  gnome-extensions install --force "$zip"
  rm -f "$zip"
}

info "Installing GNOME Shell extensions..."
for entry in "${EGO_EXTENSIONS[@]}"; do
  uuid="${entry%%:*}"
  install_ego_extension "$uuid" || true
done

for entry in "${PACKAGED_EXTENSIONS[@]}"; do
  uuid="${entry%%:*}"
  if [ ! -d "/usr/share/gnome-shell/extensions/${uuid}" ] && [ ! -d "$HOME/.local/share/gnome-shell/extensions/${uuid}" ]; then
    warn "  ${uuid} not found (expected from gnome-shell-extensions package)"
  fi
done

info "Loading extension settings..."
for entry in "${EGO_EXTENSIONS[@]}" "${PACKAGED_EXTENSIONS[@]}"; do
  uuid="${entry%%:*}"
  key="${entry##*:}"
  if [ -n "$key" ] && [ -f "$DCONF_DIR/${key}.ini" ]; then
    case "$uuid" in
      compiz-alike-magic-lamp-effect@hermes83.github.com)
        dconf load "/org/gnome/shell/extensions/ncom/github/hermes83/compiz-alike-magic-lamp-effect/" < "$DCONF_DIR/${key}.ini" ;;
      *)
        dconf load "/org/gnome/shell/extensions/${key}/" < "$DCONF_DIR/${key}.ini" ;;
    esac
  fi
done
gsettings set org.gnome.shell.extensions.user-theme name "$GTK_THEME_NAME"

# The running shell won't know about extensions just installed via
# `gnome-extensions install`, so `gnome-extensions enable` alone can't be
# relied on here - it either no-ops or errors depending on shell state. The
# authoritative switch GNOME Shell actually reads is the enabled-extensions
# key itself, so set that directly; it takes effect on next login regardless
# of whether the running shell picks extensions up immediately.
info "Enabling extensions and disabling the stock ones they replace..."
enabled_list="$(printf "'%s', " "${EGO_EXTENSIONS[@]%%:*}" "${PACKAGED_EXTENSIONS[@]%%:*}")"
gsettings set org.gnome.shell enabled-extensions "[${enabled_list%, }]"

disabled_list="$(printf "'%s', " "${STOCK_EXTENSIONS_TO_DISABLE[@]}")"
gsettings set org.gnome.shell disabled-extensions "[${disabled_list%, }]"

for entry in "${EGO_EXTENSIONS[@]}" "${PACKAGED_EXTENSIONS[@]}"; do
  uuid="${entry%%:*}"
  gnome-extensions enable "$uuid" 2>/dev/null || true
done
ok "Extensions installed, enabled, and configured"

# -- 7. Dock favorites ----------------------------------------------------------
# Personal to this machine (references apps like Spotify, VS Code, browser
# profiles); apps not installed here just show a generic icon, nothing breaks.
info "Setting dock favorites..."
gsettings set org.gnome.shell favorite-apps "$(cat "$DCONF_DIR/favorite-apps.list")"
ok "Dock favorites set"

echo ""
ok "MacUX Theme installed. Log out and back in for the shell theme and all extensions to fully apply."
echo "  Run 'bash uninstall.sh' to revert to GNOME defaults."
