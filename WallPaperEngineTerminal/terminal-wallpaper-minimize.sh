#!/usr/bin/env bash
# ==============================================================================
# 🐧 Linux Window Auto-Minimize Companion (Debian / Ubuntu / X11)
# ==============================================================================
# Purpose:
#   Direct Linux/X11 equivalent of TerminalWallpaper.ahk.
#   Monitors active window focus. When a transparent terminal (Ghostty, Alacritty,
#   Kitty, WezTerm, etc.) is focused, it automatically minimizes other normal
#   windows on the SAME MONITOR and workspace so live wallpapers (e.g.
#   wallpaper-engine-kde-plugin, linux-wallpaperengine) show cleanly behind Neovim.
#
# Requirements:
#   sudo apt install -y xdotool wmctrl x11-utils x11-xserver-utils
# ==============================================================================

set -euo pipefail

# Terminal process/class names to match (case-insensitive grep regex)
# Added Ghostty ("ghostty" and "com.mitchellh.ghostty")
TERMINAL_PATTERN="ghostty|com\.mitchellh\.ghostty|alacritty|kitty|wezterm|gnome-terminal|foot|st|xterm|urxvt|tilix|terminator"

echo "=========================================================="
echo " 🐧 Linux Terminal Wallpaper Auto-Minimize Daemon"
echo " Monitoring focus for: Ghostty, Alacritty, Kitty, WezTerm..."
echo " Press Ctrl+C to stop."
echo "=========================================================="

# Dependency check
for cmd in xdotool wmctrl xprop xwininfo xrandr; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "❌ Error: Required tool '$cmd' is not installed."
        echo "Install dependencies: sudo apt install -y xdotool wmctrl x11-utils x11-xserver-utils"
        exit 1
    fi
done

# Load connected monitor boundaries (Width Height X Y)
load_monitors() {
    MONITORS=()
    while read -r line; do
        if [[ "$line" =~ ([0-9]+)x([0-9]+)\+([0-9]+)\+([0-9]+) ]]; then
            local mw="${BASH_REMATCH[1]}"
            local mh="${BASH_REMATCH[2]}"
            local mx="${BASH_REMATCH[3]}"
            local my="${BASH_REMATCH[4]}"
            MONITORS+=("${mw} ${mh} ${mx} ${my}")
        fi
    done < <(xrandr --current 2>/dev/null | grep " connected" || true)
}

# Resolve which monitor contains a given window ID
get_window_monitor() {
    local wid="$1"
    local geom
    geom=$(xwininfo -id "$wid" 2>/dev/null || true)
    if [ -z "$geom" ]; then
        echo "0_0"
        return
    fi

    local x y w h
    x=$(echo "$geom" | awk '/Absolute upper-left X:/{print $4}')
    y=$(echo "$geom" | awk '/Absolute upper-left Y:/{print $4}')
    w=$(echo "$geom" | awk '/Width:/{print $2}')
    h=$(echo "$geom" | awk '/Height:/{print $2}')

    if [ -z "$x" ] || [ -z "$y" ] || [ -z "$w" ] || [ -z "$h" ]; then
        echo "0_0"
        return
    fi

    local cx=$((x + w / 2))
    local cy=$((y + h / 2))

    for mon in "${MONITORS[@]}"; do
        local mw mh mx my
        read -r mw mh mx my <<< "$mon"
        if [ "$cx" -ge "$mx" ] && [ "$cx" -lt "$((mx + mw))" ] && \
           [ "$cy" -ge "$my" ] && [ "$cy" -lt "$((my + mh))" ]; then
            echo "${mx}_${my}"
            return
        fi
    done

    echo "0_0"
}

load_monitors
last_active=""

clean_same_monitor() {
    local term_wid="$1"
    
    # Reload monitors in case resolution or display topology changed
    load_monitors

    # Identify the monitor where the focused terminal is located
    local term_mon
    term_mon=$(get_window_monitor "$term_wid")

    # Get active workspace index
    local current_desktop
    current_desktop=$(xdotool get_desktop 2>/dev/null || echo "0")

    # Iterate over all client windows on the current desktop
    wmctrl -l | while read -r line; do
        local wid
        wid=$(echo "$line" | awk '{print $1}')
        local desktop
        desktop=$(echo "$line" | awk '{print $2}')

        # Convert hex ID to decimal
        local dec_wid=$((wid))
        local dec_term=$((term_wid))

        # Skip the active terminal window itself
        if [ "$dec_wid" -eq "$dec_term" ]; then
            continue
        fi

        # Skip sticky / pin-to-all-workspaces windows (desktop == -1)
        if [ "$desktop" != "$current_desktop" ]; then
            continue
        fi

        # Skip already minimized / hidden windows
        local wm_state
        wm_state=$(xprop -id "$wid" _NET_WM_STATE 2>/dev/null || true)
        if [[ "$wm_state" =~ _NET_WM_STATE_HIDDEN ]]; then
            continue
        fi

        # Skip panels, docks, desktop root, system popups, and utility bars
        local win_type
        win_type=$(xprop -id "$wid" _NET_WM_WINDOW_TYPE 2>/dev/null || true)
        if [[ "$win_type" =~ _NET_WM_WINDOW_TYPE_DOCK ]] || \
           [[ "$win_type" =~ _NET_WM_WINDOW_TYPE_DESKTOP ]] || \
           [[ "$win_type" =~ _NET_WM_WINDOW_TYPE_NOTIFICATION ]] || \
           [[ "$win_type" =~ _NET_WM_WINDOW_TYPE_TOOLBAR ]] || \
           [[ "$win_type" =~ _NET_WM_WINDOW_TYPE_UTILITY ]] || \
           [[ "$win_type" =~ _NET_WM_WINDOW_TYPE_SPLASH ]]; then
            continue
        fi

        # Skip system shell elements (e.g. Plasma panel, Latte Dock, Polybar)
        local win_class
        win_class=$(xprop -id "$wid" WM_CLASS 2>/dev/null || true)
        if [[ "$win_class" =~ plasmashell|krunner|xfce4-panel|gnome-shell|polybar|tint2|latte-dock ]]; then
            continue
        fi

        # MULTI-MONITOR CHECK: Only minimize if the window is on the SAME monitor as the terminal!
        local win_mon
        win_mon=$(get_window_monitor "$wid")
        if [ "$win_mon" = "$term_mon" ]; then
            xdotool windowminimize "$wid" 2>/dev/null || true
        fi
    done

    # Ensure Ghostty retains clean foreground focus
    xdotool windowactivate "$term_wid" 2>/dev/null || true
}

# Monitor active window focus changes in X11
xprop -root -spy _NET_ACTIVE_WINDOW | while read -r line; do
    active_wid=$(echo "$line" | awk '{print $NF}')

    # Skip empty/invalid IDs or repeated triggers
    if [ "$active_wid" = "0x0" ] || [ -z "$active_wid" ] || [ "$active_wid" = "$last_active" ]; then
        continue
    fi

    # SAFETY: Debounce 150ms so Alt-Tab task switching is never interrupted
    sleep 0.15
    current_check=$(xprop -root _NET_ACTIVE_WINDOW 2>/dev/null | awk '{print $NF}')
    if [ "$current_check" != "$active_wid" ]; then
        continue
    fi

    last_active="$active_wid"

    # Verify window class matches Ghostty or other configured terminals
    win_class=$(xprop -id "$active_wid" WM_CLASS 2>/dev/null || true)
    if echo "$win_class" | grep -E -i -q "$TERMINAL_PATTERN"; then
        clean_same_monitor "$active_wid"
    fi
done
