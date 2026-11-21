-- Monitor wiki https://wiki.hypr.land/Configuring/Basics/Monitors/

-- Dual-monitor setup (2026-11-14). Matched by description, not connector,
-- so swapping cables/ports doesn't break the layout.

-- Main: HKC E2721H 27" 2K, landscape, on the left. Currently on DP-3.
-- If 120Hz flickers, drop to @100 or @60.
hl.monitor({
    output    = "desc:HKC OVERSEAS LIMITED E2721H 0000000000001",
    mode      = "2560x1440@120",
    position  = "0x0",
    scale     = "1",
})

-- Side: WAM WD215I09 21.5" 1080p, rotated to portrait, on the right. Currently on HDMI-A-1.
-- transform 1 = 90deg clockwise -> logical 1080x1920, occupying x 2560-3640.
-- y = -240 centers its 1920 height against the HKC's 1440: (1440-1920)/2.
hl.monitor({
    output    = "desc:WAM WD215I09",
    mode      = "1920x1080@100",
    position  = "2560x-240",
    scale     = "1",
    transform = 1,
})

-- Fallback for anything else plugged in later: preferred mode, placed automatically.
hl.monitor({
    output    = "",
    mode      = "preferred",
    position  = "auto",
    scale     = "auto",
})
