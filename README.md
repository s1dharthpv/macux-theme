# MacUX Theme

macOS-inspired GTK theme for Ubuntu 24.04 / GNOME Shell 46.

Includes:
- **GTK4 + GTK3 theme** — windows, buttons, menus (based on WhiteSur)
- **Icon theme** — macOS-style app icons (based on WhiteSur Icons)
- **Cursor theme** — macOS pointer (McMojave)
- Light and dark variants, auto-applies on install

## Install

```bash
git clone --recurse-submodules https://github.com/s1dharthpv/macux-theme.git
cd macux-theme
bash install.sh
```

That's it. No reboot needed.

## Uninstall

```bash
bash uninstall.sh
```

Resets everything back to GNOME defaults.

## Requirements

- Ubuntu 24.04 LTS
- GNOME Shell 46
- GTK 4.14+

## Optional — theme the top bar too

Install the [User Themes](https://extensions.gnome.org/extension/19/user-themes/) GNOME extension, then re-run `install.sh`.

## License

Based on [WhiteSur GTK Theme](https://github.com/vinceliuice/WhiteSur-gtk-theme) and
[WhiteSur Icon Theme](https://github.com/vinceliuice/WhiteSur-icon-theme) by Vince Liuice (GPL-3.0),
and [McMojave Cursors](https://github.com/vinceliuice/McMojave-cursors) by Vince Liuice (GPL-3.0).
