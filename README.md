# GridMove for Cinnamon

A GridMove-style window snapper for Linux Mint Cinnamon on X11.

Hold the middle mouse button over a window and drag. The drop zone under the
pointer lights up on whichever monitor you're over. Let go and the window snaps
into that zone.

- **Zones:** left half and right half of each monitor's work area (panels
  excluded), plus a strip along the top that maximizes the window on that
  monitor.
- **Middle click is GridMove's alone.** A plain middle click does nothing in any
  app, so there's no middle-click paste anywhere.
- **Games are left alone.** Windows with a Wine/Proton marker (`_WINE_HWND`), a
  Steam marker (`STEAM_GAME`, class `steam_app_*`), a class ending in `.exe`, or
  a class listed in `game_classes` are never moved. Middle clicks over them go
  straight to the game.
- **Lock screen:** drags are ignored while the screen is locked.
- **Cancel** a drag with a left or right click before letting go.

## Files

| In this repo | Live location |
|---|---|
| `gridmove` | `~/bin/gridmove` (a symlink to this file) |
| `config.example.json` | `~/.config/gridmove/config.json` (re-read automatically when it changes) |
| `gridmove.desktop` | `~/.config/autostart/gridmove.desktop` (starts it at login) |

Requires `python3-xlib`, PyGObject (GTK 3) and `wmctrl`. Nothing else may grab
the middle button. xbindkeys must stay off.

## Running

```sh
journalctl -t gridmove -f                    # log, one line per snap
pkill -f 'bin/gridmove$'                     # stop
setsid -f systemd-cat -t gridmove ~/bin/gridmove    # start
GRIDMOVE_DEBUG=1 ~/bin/gridmove              # run in the foreground, log every event
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

Zone values are fractions of the monitor's work area. `trigger` is the part of
the screen that selects a zone (it defaults to the zone itself). The first
matching zone wins. An invalid file is rejected and the previous config kept.
