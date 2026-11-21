hl.config({
    dwindle = {
        preserve_split = true,
    },
    misc = {
        col = {
            splash = CACHYLGREEN,
        },
        middle_click_paste = false,
        enable_swallow = true,
        swallow_regex = "(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)",
        vrr = 3,
    },
    -- Software cursor: NVIDIA hardware cursor is missing from screen recordings/screen share
    cursor = {
        no_hardware_cursors = 1,
    },
    -- Don't flip monitors into HDR when fullscreen video is HDR: neither the HKC
    -- nor the WAM can really show it, so video went dull/washed out. (2026-11-20)
    render = {
        cm_auto_hdr = 0,
    },
    xwayland = {
        force_zero_scaling = true
    },
    ecosystem = {
        no_update_news = true,
        no_donation_nag = true,
    },
})