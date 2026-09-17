# MacUX Theme

A macOS-look desktop for Ubuntu 24.04 / GNOME Shell 46 - one clone, one
script, the exact setup below.

## What you get

- **GTK3 + GTK4/libadwaita theme** - WhiteSur, dark, alt window-control
  buttons, blue accent (`WhiteSur-Dark-alt-blue`)
- **Icons** - WhiteSur icon theme, blue, dark variant
- **Cursors** - WhiteSur cursors
- **Fonts** - SF Pro Text/Display/Rounded (UI) and Source Code Pro
  (monospace), fetched at install time (see [Fonts](#fonts) below)
- **8 GNOME Shell extensions**, pre-configured to match:
  - [Dash2Dock Lite](https://extensions.gnome.org/extension/4994/dash2dock-lite/) - animated macOS-style dock
  - [Quick Settings Tweaks](https://extensions.gnome.org/extension/5446/quick-settings-tweaks/) - trimmed quick settings + compact weather
  - [Search Light](https://extensions.gnome.org/extension/5489/search-light/) - Spotlight-style app search (`Ctrl+Q`)
  - [Customize Clock on Lock Screen](https://extensions.gnome.org/extension/4977/customize-clock-on-lockscreen/) - LED-style lock screen clock
  - [Blur my Shell](https://extensions.gnome.org/extension/3193/blur-my-shell/) - blurred panel/dock/overview
  - [Compiz Alike Magic Lamp Effect](https://extensions.gnome.org/extension/3740/compiz-alike-magic-lamp-effect/) - genie window minimize animation
  - **System Monitor** and **User Themes** - from Ubuntu's `gnome-shell-extensions` package
- **Stock Ubuntu extensions turned off** - `ubuntu-dock`, `ding` (desktop icons),
  `tiling-assistant`, `ubuntu-appindicators`, and the rest of the default GNOME
  bundle, so they don't double up with the dock/panel above
- **Touchpad** - natural scroll, tap-to-click
- **Dock favorites** - the exact app list from the source machine (apps you
  don't have installed just show a generic icon, nothing breaks)

## Install

```bash
git clone https://github.com/s1dharthpv/macux-theme.git
cd macux-theme
bash install.sh
```

`install.sh` pulls in the theme/icon/cursor submodules itself (no need for
`--recurse-submodules`), installs apt dependencies (asks for `sudo`), fetches
fonts and extensions, applies every setting, and enables everything. **Log
out and back in afterwards** - GNOME only fully loads a new shell theme and
newly-installed extensions on a fresh session.

## Uninstall

```bash
bash uninstall.sh
```

Removes the theme/icon/cursor/font files, resets every setting this repo
touched back to GNOME defaults, and removes the extensions it installed.
`system-monitor` / `user-theme` come from Ubuntu's own package and are left
alone.

## Fonts

Apple's SF Pro fonts are proprietary - their license covers developing for
Apple platforms, not redistribution in a Linux theme repo, so **no font
files are committed here**. `install.sh` downloads them at install time from
[sahibjotsaggu/San-Francisco-Pro-Fonts](https://github.com/sahibjotsaggu/San-Francisco-Pro-Fonts),
a long-standing unofficial community mirror used by similar theme projects -
same legal footing as those, not a guarantee from Apple. Source Code Pro
comes from Adobe's official open-source (SIL OFL) repository, no such
caveat applies.

If you'd rather not pull SF Pro from a third-party mirror, comment out the
SF Pro block in `install.sh`'s font step and drop your own `.otf` files in
`~/.local/share/fonts/` instead.

## Requirements

- Ubuntu 24.04 LTS, GNOME Shell 46
- `sudo` access (for apt dependencies and the `gnome-shell-extensions` package)
- Internet access during install (submodules, fonts, and 6 of the 8 extensions
  are fetched, not vendored)

## Notes

- Window borders (`org.gnome.desktop.wm.preferences theme`) are left on
  Ubuntu's stock `Yaru-dark` - GNOME apps use client-side decorations, so
  this is only visible on the few apps that still draw server-side titlebars.
- Extension settings are stored under `dconf/*.ini` and loaded with
  `dconf load` - edit those files (then re-run `install.sh`, or
  `dconf load <path>/ < file.ini` directly) to tweak dock size, blur
  strength, the search shortcut, etc.

## License

This repo is just install/uninstall glue plus a settings snapshot - no
theme code of its own. Everything it installs keeps its upstream license:

- [WhiteSur GTK Theme](https://github.com/vinceliuice/WhiteSur-gtk-theme),
  [WhiteSur Icon Theme](https://github.com/vinceliuice/WhiteSur-icon-theme),
  [WhiteSur Cursors](https://github.com/vinceliuice/WhiteSur-cursors) - GPL-3.0, by Vince Liuice
- Dash2Dock Lite, Quick Settings Tweaks, Search Light, Customize Clock on
  Lock Screen, Blur my Shell, Compiz Alike Magic Lamp Effect - GPL, by their
  respective authors (see links above)
- Source Code Pro - SIL Open Font License, by Adobe
- SF Pro - © Apple Inc., fetched from an unofficial mirror at install time; not redistributed by this repo
