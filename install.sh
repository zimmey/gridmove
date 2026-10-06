#!/usr/bin/env bash
# Install or uninstall GridMove for the current user.
#
#   ./install.sh               install, then start GridMove
#   ./install.sh --no-start    install only
#   ./install.sh --uninstall   stop GridMove and remove the link and autostart entry
#                              (your config is left in place)
#
# BIN_DIR picks where the program link goes (default ~/.local/bin).
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
TARGET="$BIN_DIR/gridmove"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
CONFIG="$CONFIG_DIR/gridmove/config.json"
AUTOSTART="$CONFIG_DIR/autostart/gridmove.desktop"

say()  { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

stop_running() {
    # Only stop a GridMove started from this install's path.
    pkill -f -x "python3 $TARGET" 2>/dev/null && sleep 0.5 || true
}

start() {
    if command -v systemd-cat >/dev/null; then
        setsid -f systemd-cat -t gridmove "$TARGET" </dev/null
        say "Started. Log: journalctl -t gridmove -f"
    else
        setsid -f "$TARGET" </dev/null >/dev/null 2>&1
        say "Started."
    fi
}

uninstall() {
    stop_running
    if [ -L "$TARGET" ] && [ "$(readlink -f "$TARGET")" = "$REPO/gridmove" ]; then
        rm "$TARGET"; say "Removed $TARGET"
    elif [ -e "$TARGET" ]; then
        warn "$TARGET is not a link to this repo; left it alone"
    fi
    if [ -f "$AUTOSTART" ] && grep -q "$TARGET" "$AUTOSTART"; then
        rm "$AUTOSTART"; say "Removed $AUTOSTART"
    fi
    say "Config left in place: $CONFIG"
    say "Note: middle-click paste comes back once GridMove stops holding the middle button."
}

check_deps() {
    local missing=()
    python3 -c 'import Xlib' 2>/dev/null || missing+=(python3-xlib)
    python3 -c 'import gi; gi.require_version("Gtk", "3.0"); from gi.repository import Gtk' \
        2>/dev/null || missing+=(python3-gi gir1.2-gtk-3.0)
    python3 -c 'import gi; gi.require_foreign("cairo")' 2>/dev/null || missing+=(python3-gi-cairo)
    command -v wmctrl >/dev/null || missing+=(wmctrl)
    if [ ${#missing[@]} -gt 0 ]; then
        say "Missing dependencies. Install them with:"
        say "  sudo apt install ${missing[*]}"
        exit 1
    fi
}

install() {
    [ "${XDG_SESSION_TYPE:-x11}" = "x11" ] \
        || warn "this session is ${XDG_SESSION_TYPE}; GridMove only works on X11"
    check_deps

    mkdir -p "$BIN_DIR"
    if [ -e "$TARGET" ] && ! [ -L "$TARGET" ]; then
        die "$TARGET exists and is not a link; move it aside first"
    fi
    ln -sfn "$REPO/gridmove" "$TARGET"
    say "Linked $TARGET -> $REPO/gridmove (a git pull updates it)"

    if [ -f "$CONFIG" ]; then
        say "Kept existing config: $CONFIG"
    else
        mkdir -p "$(dirname "$CONFIG")"
        cp "$REPO/config.example.json" "$CONFIG"
        say "Installed config: $CONFIG"
    fi

    local exec_line="$TARGET"
    command -v systemd-cat >/dev/null && exec_line="$(command -v systemd-cat) -t gridmove $TARGET"
    mkdir -p "$(dirname "$AUTOSTART")"
    cat > "$AUTOSTART" <<EOF
[Desktop Entry]
Type=Application
Name=GridMove
Comment=Middle-drag windows into snap zones
Exec=$exec_line
X-GNOME-Autostart-enabled=true
EOF
    say "Installed autostart entry: $AUTOSTART"

    if pgrep -x xbindkeys >/dev/null && grep -qs '^\s*b:2' "$HOME/.xbindkeysrc"; then
        warn "xbindkeys is bound to the middle button (~/.xbindkeysrc), so GridMove can't grab it."
        warn "Remove that binding and restart xbindkeys, or turn xbindkeys off."
    fi

    if [ "$NO_START" = 1 ]; then
        say "Not starting (--no-start)."
    else
        stop_running
        start
    fi
}

NO_START=0
case "${1:-}" in
    "") install ;;
    --no-start) NO_START=1; install ;;
    --uninstall) uninstall ;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//' ;;
    *) die "unknown option: $1 (try --help)" ;;
esac
