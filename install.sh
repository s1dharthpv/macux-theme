#!/usr/bin/env bash
# MacUX Theme — one-command installer
# Installs GTK theme, icons, and cursors then applies them automatically.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GTK_DIR="$HOME/.themes"
ICON_DIR="$HOME/.icons"
THEME_NAME="MacUX"
ICON_NAME="MacUX-Icons"
CURSOR_NAME="MacUX-Cursors"

GREEN='\033[0;32m'; CYAN='\033[0;36m'; RESET='\033[0m'
info()  { echo -e "${CYAN}▶ $*${RESET}"; }
ok()    { echo -e "${GREEN}✔ $*${RESET}"; }

# ── 1. Directories ────────────────────────────────────────────────────────────
mkdir -p "$GTK_DIR" "$ICON_DIR"

# ── 2. GTK theme ─────────────────────────────────────────────────────────────
info "Installing GTK theme..."
cd "$SCRIPT_DIR/WhiteSur-gtk-theme"
bash install.sh \
    --name MacUX \
    --color light dark \
    --accent blue \
    --dest "$GTK_DIR" \
    --silent-mode
ok "GTK theme installed"

# ── 3. Icons ──────────────────────────────────────────────────────────────────
info "Installing icons..."
cd "$SCRIPT_DIR/WhiteSur-icon-theme"
bash install.sh \
    --name MacUX-Icons \
    --dest "$ICON_DIR" \
    --silent-mode
ok "Icons installed"

# ── 4. Cursors ────────────────────────────────────────────────────────────────
info "Installing cursors..."
cd "$SCRIPT_DIR/McMojave-cursors"
# McMojave ships pre-built cursor files; just copy them
if [ -d "dist" ]; then
    cp -r dist/McMojave-cursors "$ICON_DIR/$CURSOR_NAME"
elif [ -d "McMojave-cursors" ]; then
    cp -r McMojave-cursors "$ICON_DIR/$CURSOR_NAME"
else
    # Build from source if needed
    if command -v make &>/dev/null; then
        make 2>/dev/null || true
        [ -d "dist" ] && cp -r dist/McMojave-cursors "$ICON_DIR/$CURSOR_NAME" || \
        cp -r . "$ICON_DIR/$CURSOR_NAME"
    else
        cp -r . "$ICON_DIR/$CURSOR_NAME"
    fi
fi
ok "Cursors installed"

# ── 5. Apply via gsettings ────────────────────────────────────────────────────
info "Applying theme..."
gsettings set org.gnome.desktop.interface gtk-theme        "MacUX"
gsettings set org.gnome.desktop.interface icon-theme       "MacUX-Icons"
gsettings set org.gnome.desktop.interface cursor-theme     "MacUX-Cursors"
gsettings set org.gnome.desktop.interface font-name        "SF Pro Display 11"    2>/dev/null || \
gsettings set org.gnome.desktop.interface font-name        "Inter 11"             2>/dev/null || true
gsettings set org.gnome.desktop.wm.preferences theme       "MacUX"
gsettings set org.gnome.desktop.wm.preferences button-layout "close,minimize,maximize:"
ok "Theme applied"

# ── 6. Apply GNOME Shell theme (if user-theme extension is active) ────────────
if gnome-extensions list --enabled 2>/dev/null | grep -q "user-theme"; then
    gsettings set org.gnome.shell.extensions.user-theme name "MacUX"
    ok "GNOME Shell theme applied"
else
    echo ""
    echo "  Tip: install the 'User Themes' GNOME extension to also theme the top bar:"
    echo "  https://extensions.gnome.org/extension/19/user-themes/"
fi

echo ""
echo "  MacUX Theme installed successfully."
echo "  Log out and back in if window decorations don't update immediately."
