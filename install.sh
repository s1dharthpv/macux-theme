#!/usr/bin/env bash
# MacUX Theme — one-command installer
# Installs GTK theme, icons, and cursors then applies them automatically.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'; CYAN='\033[0;36m'; RESET='\033[0m'
info() { echo -e "${CYAN}▶ $*${RESET}"; }
ok()   { echo -e "${GREEN}✔ $*${RESET}"; }

# ── 1. GTK theme ─────────────────────────────────────────────────────────────
info "Installing GTK theme..."
cd "$SCRIPT_DIR/WhiteSur-gtk-theme"
bash install.sh \
    --name MacUX \
    --color light --color dark \
    --theme blue \
    --dest "$HOME/.themes"
ok "GTK theme installed  →  ~/.themes/MacUX  ~/.themes/MacUX-Dark"

# ── 2. Icons ──────────────────────────────────────────────────────────────────
info "Installing icons..."
cd "$SCRIPT_DIR/WhiteSur-icon-theme"
bash install.sh \
    --name MacUX-Icons \
    --dest "$HOME/.local/share/icons"
ok "Icons installed  →  ~/.local/share/icons/MacUX-Icons"

# ── 3. Cursors ────────────────────────────────────────────────────────────────
info "Installing cursors..."
cd "$SCRIPT_DIR/McMojave-cursors"
mkdir -p "$HOME/.local/share/icons"
cp -r dist "$HOME/.local/share/icons/MacUX-Cursors"
ok "Cursors installed  →  ~/.local/share/icons/MacUX-Cursors"

# ── 4. Apply via gsettings ────────────────────────────────────────────────────
info "Applying theme..."
gsettings set org.gnome.desktop.interface gtk-theme            "MacUX"
gsettings set org.gnome.desktop.interface icon-theme           "MacUX-Icons"
gsettings set org.gnome.desktop.interface cursor-theme         "MacUX-Cursors"
gsettings set org.gnome.desktop.wm.preferences theme           "MacUX"
gsettings set org.gnome.desktop.wm.preferences button-layout   "close,minimize,maximize:"
ok "Theme applied"

# ── 5. GNOME Shell theme (only if User Themes extension is enabled) ───────────
if gnome-extensions list --enabled 2>/dev/null | grep -q "user-theme"; then
    gsettings set org.gnome.shell.extensions.user-theme name "MacUX"
    ok "GNOME Shell theme applied"
else
    echo ""
    echo "  Tip: to also theme the top bar, install the 'User Themes' extension:"
    echo "  https://extensions.gnome.org/extension/19/user-themes/"
    echo "  Then re-run this script."
fi

echo ""
ok "MacUX Theme installed. Enjoy your desktop!"
echo "  Run 'bash uninstall.sh' to revert to GNOME defaults."
