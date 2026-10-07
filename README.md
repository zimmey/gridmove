# GridMove for Cinnamon

A GridMove-style window snapper for Linux Mint Cinnamon on X11.

Inspired by [GridMove](https://www.dcmembers.com/jgpaiva/) by jgpaiva, the
original drag-to-grid window manager for Windows. This is an independent
reimplementation for Linux and shares no code with it.

Hold the middle mouse button over a window and drag. The drop zone under the
pointer lights up on whichever monitor you're over. Let go and the window snaps
into that zone.

- **Zones:** left half and right half of each monitor's work area (panels
  excluded), plus a strip along the top that maximizes the window on that
  monitor.
- **Middle click is GridMove's alone.** A plain middle click does nothing in any
  app, so there's no middle-click paste anywhere.
- **Games are left alone.** Steam games (the `STEAM_GAME` tag or a
  `steam_app_*`/`steam_proton` class) and any class listed in `game_classes`
  are never moved. Other Wine windows (`_WINE_HWND` or an `.exe` class) count
  as games only when they're full screen or have no title bar, so ordinary
  Wine apps still snap. Middle clicks over a game go straight to the game.
- **Lock screen:** drags are ignored while the screen is locked.
- **Cancel** a drag with a left or right click before letting go.

## Install

```sh
git clone https://github.com/zimmey/gridmove.git
cd gridmove
./install.sh
```

The installer checks dependencies (it prints the `apt install` line if any are
missing), links `~/.local/bin/gridmove` to the repo copy so a `git pull`
updates it, installs `~/.config/gridmove/config.json` if you don't have one,
adds a login autostart entry, and starts GridMove.

- `./install.sh --no-start` installs without starting.
- `./install.sh --uninstall` stops GridMove and removes the link and autostart
  entry. Your config stays.
- `BIN_DIR=~/bin ./install.sh` puts the link somewhere other than `~/.local/bin`.

Requires an X11 session, `python3-xlib`, PyGObject with GTK 3 and cairo, and
`wmctrl`. Nothing else may grab the middle button. If xbindkeys has a `b:2`
binding, the installer warns you, and you'll need to remove that binding.

Middle-click paste stays off for as long as GridMove is running.

## Running

```sh
journalctl -t gridmove -f                    # log, one line per snap
pkill -f 'bin/gridmove$'                     # stop
./install.sh                                 # (re)start
GRIDMOVE_DEBUG=1 ~/.local/bin/gridmove       # run in the foreground, log every event
```

If the mouse ever freezes, the keyboard still works: alt-tab to a terminal and
run `pkill -f 'bin/gridmove$'`.

## Config

```json
{
  "drag_threshold": 10,
  "gap": 0,
  "game_classes": [],
  "zones": [
    {"name": "maximize", "action": "maximize", "x": 0, "y": 0, "w": 1, "h": 1,
     "trigger": {"x": 0, "y": 0, "w": 1, "h": 0.06}},
    {"name": "left half", "x": 0, "y": 0, "w": 0.5, "h": 1},
    {"name": "right half", "x": 0.5, "y": 0, "w": 0.5, "h": 1}
  ]
}
```

The config lives in `~/.config/gridmove/config.json` (or under
`$XDG_CONFIG_HOME` if you've set it). Zone values are fractions of the
monitor's work area. `trigger` is the part of the screen that selects a zone
(it defaults to the zone itself). The first matching zone wins. An invalid file
is rejected and the previous config kept.

## License

MIT. See [LICENSE](LICENSE).
