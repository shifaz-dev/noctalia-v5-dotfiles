-- Auto-start config
-- if you dont use UWSM add your auto start programs here, otherwise use XDG autostart https://wiki.archlinux.org/title/XDG_Autostart

hl.on("hyprland.start", function ()
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("noctalia")
    hl.exec_cmd("xhost +SI:localuser:root")
    -- Mark the 2K monitor as primary in XWayland so games (eFootball etc.) pick it and offer 2560x1440
    -- Retry: XWayland may not be up yet, and a fixed sleep 2 wasn't enough
    -- Connector is looked up by model (HKC E2721H) so it survives cable/port swaps
    hl.exec_cmd("sh -c 'for i in $(seq 30); do O=$(hyprctl monitors -j 2>/dev/null | jq -r \".[] | select(.model==\\\"E2721H\\\") | .name\"); [ -n \"$O\" ] && xrandr --listmonitors 2>/dev/null | grep -q \"\\*$O\" && exit; [ -n \"$O\" ] && xrandr --output \"$O\" --primary 2>/dev/null; sleep 1; done'")
end)
