# Noctalia v5 — Config & IPC Reference

> Compiled 2026-07-11 from all ~30 pages of docs.noctalia.dev/v5 + `noctalia config export full` on this machine.
> Machine: Hyprland (Lua-native) on CachyOS, RTX 5060. Binary = `noctalia`, IPC = `noctalia msg`.
> Palette in use: **Peche** (custom). Themed HTML version: `noctalia-v5-reference.html` (same folder).
> When in doubt the running binary is authoritative: `noctalia msg --help`, `noctalia config export full`.

---

## 0. v4 → v5 in one line
No auto-migration. v4 was Quickshell + JSON, launched via `qs -c noctalia-shell`. v5 is a native
C++/OpenGL binary + **TOML**, launched via `noctalia`, IPC via `noctalia msg …`. v4 and v5 can coexist
(different formats/paths). Custom **palettes are the same JSON format** in both — they drop straight in.

---

## 1. How config works (the key mental model)

Two layers, last-wins:

| Layer | Path | Role |
|---|---|---|
| Your hand-edited config | `~/.config/noctalia/*.toml` | Base. **Every** `*.toml` in the folder is read (alphabetical merge, non-recursive). Recommended for dotfiles. |
| GUI-managed overrides | `~/.local/state/noctalia/settings.toml` | Written by Settings UI / setup wizard / IPC. **Loads last → wins.** |
| Internal UI state | `~/.local/state/noctalia/state.toml` | Last-used values, not a config file. |

- Dir resolution: `$NOCTALIA_CONFIG_HOME/noctalia/` → `$XDG_CONFIG_HOME/noctalia/` → `~/.config/noctalia/`.
  State: `$NOCTALIA_STATE_HOME` → `$XDG_STATE_HOME` → `~/.local/state/noctalia/`.
- **"Why is my hand-edited setting ignored?"** → the same key exists in `settings.toml`, which loads last. Inspect/clear it there.
- Both layers hot-reload automatically.

**Load order:** built-in defaults → your `*.toml` (each file's `[include]` first, then its own keys) → `settings.toml`.

**Splitting / includes** (in your files only, ignored in settings.toml):
```toml
[include]
files = [
  "widgets/",                    # every *.toml in dir, sorted, non-recursive
  "bars/top.toml",               # single file
  "~/.config/shared/base.toml",  # ~, $VAR, ${VAR} expanded
]
# autoload = false   → load ONLY this file + its includes (profile switching)
```
Relative paths resolve from the including file's dir; the including file's own keys win; cycles skipped.

**CLI**
| Command | Does |
|---|---|
| `noctalia config export` | Merged **user** config → stdout (best for dotfiles) |
| `noctalia config export full` | Full effective config incl. all defaults (the real schema) |
| `noctalia config validate [path]` | TOML syntax + unknown/obsolete keys + bad enums (exit 1 on error) |
| `noctalia msg config-reload` | Reload the merged stack now |

---

## 2. Theme & palette — `[theme]`

```toml
[theme]
mode              = "dark"        # dark | light | auto  (auto follows [location] sun times)
source            = "custom"      # builtin | wallpaper | community | custom
custom_palette    = "Peche"       # filename WITHOUT .json in palettes/  (when source=custom)
builtin           = "Noctalia"    # when source=builtin
community_palette = "Oxocarbon"   # when source=community
wallpaper_scheme  = "m3-content"  # when source=wallpaper
```

**Recreate Peche**
1. Copy scheme → `~/.config/noctalia/palettes/Peche.json`
2. `source="custom"`, `custom_palette="Peche"`  (or live: `noctalia msg color-scheme-set custom Peche`)
3. v4 migration path was `colorschemes/Peche/Peche.json` → v5 `palettes/Peche.json`

**Palette JSON shape** (same as v4): top-level `"dark"` + optional `"light"`. If `light` omitted, dark used for both.
16 role keys per variant + a `terminal` object.

| Role (settings name) | JSON key |  | Role | JSON key |
|---|---|---|---|---|
| primary | `mPrimary` | | on_primary | `mOnPrimary` |
| secondary | `mSecondary` | | on_secondary | `mOnSecondary` |
| tertiary | `mTertiary` | | on_tertiary | `mOnTertiary` |
| error | `mError` | | on_error | `mOnError` |
| surface | `mSurface` | | on_surface | `mOnSurface` |
| surface_variant | `mSurfaceVariant` | | on_surface_variant | `mOnSurfaceVariant` |
| outline | `mOutline` | | shadow | `mShadow` |
| hover | `mHover` | | on_hover | `mOnHover` |

`terminal` = `{ background, foreground, cursor, cursorText, selectionBg, selectionFg, normal{8 ansi}, bright{8 ansi} }`.
ANSI keys: black red green yellow blue magenta cyan white. Hex `#RGB`/`#RGBA`/`#RRGGBB`/`#RRGGBBAA`.

**Builtins:** Ayu, Catppuccin, Dracula, Eldritch, Gruvbox, Kanagawa, Noctalia, Nord, Rosé Pine, Tokyo-Night. (Unknown → falls back to Noctalia.)
**Wallpaper generators:** m3-tonal-spot, m3-content, m3-fruit-salad, m3-rainbow, m3-monochrome, vibrant, faithful, soft, dysfunctional, muted.
**Community palettes** cached in `~/.local/state/noctalia/community-palettes/` (offline-capable).

---

## 3. Bar — `[bar.<name>]`

Bars are named tables; each spawns on every monitor, then per-monitor overrides refine. `[bar] order = [...]` sets layer-creation order (matters only for `reserve_space` bars).

```toml
[bar.default]
position   = "top"        # top | bottom | left | right
thickness  = 34
background_opacity = 0.35
border     = "outline"    # role name or #RRGGBB
border_width = 0.0
margin_edge  = 2          # >0 floats the bar (the old "floating" look)
margin_ends  = 100        # inset from each end of main axis
radius       = 12         # + radius_top_left/... per corner; NEGATIVE = concave spike (inner corners only)
scale        = 1.0        # bar content scale
font_weight  = "regular"  # regular | bold ; font_family "" = inherit global
auto_hide    = false
layer        = "top"      # top | overlay (overlay = above fullscreen)
reserve_space = true
capsule      = false      # pill bg behind widgets; capsule_fill/opacity/padding/radius/thickness
start  = ["launcher", "workspaces", "active_window"]
center = ["media", "clock", "sysmon"]
end    = ["tray", "notifications", "volume", "brightness", "control-center", "session"]

[bar.default.dead_zone]           # actions on empty bar margin
right_command = ""                # empty = open Control Center; also command/middle/scroll_up/down_command

[bar.default.monitor."DP-1"]      # per-monitor override; FIRST MATCH WINS (file order)
position = "top"                  # match = connector name OR description substring ("LG","4K")
# enabled = false                 # → remove this bar from that output
```

Capsule groups: `[[bar.<name>.capsule_group]]` with `id`, `members`; reference in a lane as `group:<id>`.

---

## 4. Bar widgets — `[widget.<name>]`

A lane entry is a widget name. Add `[widget.<name>]` with `type` to configure it (or run two of a kind).
A bare name with no table = that name used as the type with defaults. `type` defaults to `<name>`.

```toml
[widget.clock]
type   = "clock"
format = "{:%H:%M  %a, %d %b}"   # strftime tokens; \n for two lines; also vertical_format, tooltip_format

[widget.sysmon]                  # one instance per stat; add several
type = "sysmon"
stat = "cpu_temp"
```

**All widget types:**
clock, spacer, workspaces, taskbar, active_window, control-center, sysmon, volume, audio_visualizer,
media, privacy, battery, brightness, bluetooth, network, keyboard_layout, lock_keys, launcher,
custom_button, clipboard, screenshot, weather, notifications, tray, power_profile, caffeine, nightlight,
theme_mode, settings, session, wallpaper.
Plugin widget: `type = "<author>/<plugin>:<entry>"`.

**sysmon `stat` values:**
| stat | shows | stat | shows |
|---|---|---|---|
| `cpu_usage` | CPU % | `ram_used` / `ram_pct` | RAM used / % |
| `cpu_temp` | CPU °C | `swap_pct` | Swap % |
| `gpu_temp` | GPU °C (NVML on NVIDIA) | `disk_pct` | Disk % (`path` key) |
| `gpu_vram` | VRAM % (NVML on NVIDIA) | `net_rx` / `net_tx` | down / up (`interface` key) |

**RTX 5060:** only `gpu_temp` + `gpu_vram` (NVML fallback); no gpu-usage% stat. Poll cadence is global `[system.monitor]`.

Selected widget keys: `clock.format`; `spacer.length`; `workspaces` (display id/name/none, pill sizes, colors);
`active_window` (min/max_length, display icon_and_text/icon_only/text_only, title_scroll);
`volume` (device output/input, scroll_step, show_label); `media` (min/max_length, art_size, hide_when_no_media);
`battery` (display_mode icon/graphic, warning_threshold); `tray` (hidden[], pinned[], drawer);
`custom_button` (label, command, right/middle/scroll commands). Universal: `scale` (0.2–2.5), `enabled`, capsule_* overrides.

---

## 5. Dock — `[dock]`  (disabled by default)

```toml
[dock]
enabled  = true
position = "bottom"                # top|bottom|left|right
monitors = ["HDMI-A-1", "DP-1"]    # empty = all outputs
pinned   = ["firefox", "kitty", "org.kde.dolphin", "vivaldi-stable"]
auto_hide = false
launcher_position = "none"         # none | start | end
magnification = true               # magnification_scale 1.35
show_running = true
icon_size = 48                     # background_opacity 0.88, radius 16, show_dots, show_instance_count
```
`pinned` match order: desktop-entry stem → StartupWMClass → app Name → full path. No match = placeholder slot.

---

## 6. Control center — `[control_center]`

```toml
[control_center]
sidebar = "compact"   # full | compact | none
width   = 680
hidden_tabs = []

[[control_center.shortcuts]]        # max 6 shown on Home
type = "wifi"
[[control_center.shortcuts]]
type = "bluetooth"
```
**Shortcut types:** wifi, bluetooth, nightlight, notification (=DND), dark_mode, caffeine, audio, mic_mute,
power_profile, media, weather, system, screen_time, keyboard_layout, wallpaper, session, clipboard.
Default set: wifi, bluetooth, caffeine, nightlight, notification, power_profile.
**Tab context ids** (for `panel-toggle control-center <tab>`): home, media, audio, monitor, system, network,
bluetooth, weather, calendar, notifications, screen-time, power.

---

## 7. Wallpaper — `[wallpaper]` / backdrop — `[backdrop]`

| Key | Default | Notes |
|---|---|---|
| `enabled` | true | `false` = bar-only, no wallpaper (old perf setting) |
| `directory` | — | picker folder; `directory_light` / `directory_dark` per mode |
| `fill_mode` | crop | center · crop · fit · stretch · repeat · `span` (across monitors) |
| `fill_color` | `#111111` | role name or hex; used behind/around image |
| `transition` | all | random from `["fade","wipe","disc","stripes","zoom","honeycomb"]` |
| `transition_duration` | 1500 | ms; `transition_on_startup` false |
| `per_monitor_directories` | false | enables `[wallpaper.monitor.<name>]` overrides |

```toml
[wallpaper.default]      # path = initial wallpaper for all outputs
[wallpaper.automation]
enabled = true
interval_seconds = 1800
order = "random"          # random | alphabetical
recursive = true
```
`[backdrop]` = blurred/tinted copy for compositor overview: `enabled`, `blur_intensity`, `tint_intensity`.

---

## 8. Desktop widgets — `[desktop_widgets]`

Free-floating layer-shell surfaces placed by pixel coord per output. Build with the visual editor, then export.

```toml
[desktop_widgets.widget.clock_main]
type   = "clock"     # button clock label sysmon weather media_player sticker audio_visualizer fancy_audio_visualizer
output = "DP-1"
cx = 1200            # center X/Y logical px; box_width/height 0.0 = auto-fit; rotation in radians
cy = 280
[desktop_widgets.widget.clock_main.settings]
clock_style = "digital"   # digital | analog
format = "{:%H:%M}"
```
Editor: `noctalia msg desktop-widgets-toggle-edit` (drag=move, ring=rotate, corner=resize, `G`=grid, `Delete`=remove).
Common settings: `background`, `background_color`, `background_radius`, `color`, `shadow`.
Then Settings → Export → Merged User Config to make it declarative.

---

## 9. Services (each a top-level table)

- **`[weather]`** — `enabled`, `unit` (metric/imperial), `refresh_minutes` (30), `effects`. **Requires `[location]`** (`auto_locate` or `address`). Open-Meteo, 6-day forecast.
- **`[notification]`** — `enable_daemon`, `position` (top_right…), `layer` (top/overlay), `scale`, `background_opacity`, `offset_x/y`, `monitors[]`, `collapse_on_dismiss`. Filters: `[notification.filter.<name>]`. DND is IPC-only.
- **`[brightness]`** — `enable_ddcutil`, `minimum_brightness`, `sync_all_monitors`, `ignore_mmids[]`. Per-display `[brightness.monitor.<name>].backend` = auto|backlight|ddcutil|none.
- **`[nightlight]`** — `enabled`, `temperature_day` (6500), `temperature_night` (4000), `force`. Schedule from `[location]`.
- **`[audio]`** — `enable_overdrive` (→150%), `enable_sounds`, `sound_volume`, `volume_change_sound`, `notification_sound`.
- **`[idle]` + `[idle.behavior.<name>]`** — action lock|screen_off|suspend|lock_and_suspend|command, `timeout`, `command`, `resume_command`, `lock_before_suspend`. Top-level `pre_action_fade_seconds` (2.0). `command` supports `noctalia:<ipc>`.
- **`[osd]`** — `position`, `orientation`, `scale`, `background_opacity`, `offset_x/y`, `monitors[]`; `[osd.kinds]` toggles.
- **`[lockscreen]`** — `enabled`, `fingerprint`, `allow_empty_password`, `blurred_desktop`, `blur_intensity`, `wallpaper`, `monitors[]`.

---

## 10. Shell — `[shell]` (global)

Notable keys: `font_family` (single Pango family for ALL shell text — **no separate mono field**), `ui_scale`,
`corner_radius_scale`, `avatar_path`, `time_format` (`{:%H:%M}`), `date_format` (`%A, %x`), `offline_mode`,
`polkit_agent`, `password_style`, `clipboard_enabled`, `clipboard_history_max_entries` (100), `clipboard_auto_paste`,
`launch_apps_as_systemd_services`, `launch_apps_custom_command` (`$CMD` wrap), `app_icon_colorize`, `screen_time_enabled`.
Subtables: `[shell.animation]` (enabled, speed), `[shell.shadow]` (direction, alpha), `[shell.panel]` (placements
attached/floating/centered, transparency_mode), `[shell.launcher]` (categories, show_icons, compact, app_grid, sort_by_usage),
`[shell.screenshot]` (directory, filename_pattern, copy_to_clipboard, pipe_command e.g. `satty -f -`),
`[shell.session]` + `[[shell.session.actions]]` (lock/logout/suspend/lock_and_suspend/reboot/shutdown/command,
shortcut, countdown_seconds, variant), `[shell.mpris].blacklist`, `[shell.screen_corners]`.
Top-level extras: `[hot_corners]`, `[keybinds]` (validate/cancel/left/right/up/down/tab_next/tab_previous —
**super/meta NOT allowed** as chord mods, only ctrl/shift/alt).

**Date/time tokens:** bare strftime `%H:%M` OR chrono `{:%H:%M}` (interchangeable). `\n` = newline, `%%` = literal %.
Follows `LC_TIME`. First-day-of-week is NOT configurable (follows locale). Examples: `{:%-I:%M %p}`→`9:05 AM`.

---

## 11. IPC cheat-sheet — `noctalia msg <cmd>`

In config fields (idle/hooks) use `noctalia:<cmd>` shorthand. Full list: `noctalia msg --help`.

**Panels / surfaces**
```
panel-toggle launcher [query]          # e.g. /emo, "/wall"
panel-toggle control-center [tab]      # e.g. media, notifications
panel-toggle session | clipboard | wallpaper
panel-open <id> [context] ; panel-close [id]
bar-toggle | bar-show | bar-hide [name] [monitor]
bar-layer-set <top|overlay> ; bar-auto-hide-set <on|off>
dock-toggle | dock-show | dock-hide
settings-toggle [context] ; settings-open [context]
window-switcher
desktop-widgets-toggle-edit | desktop-widgets-toggle
```
**System controls**
```
volume-up | volume-down | volume-mute | volume-set 65%
mic-mute | mic-volume-up | mic-volume-set 0.5
brightness-up | brightness-down [target] [step]
brightness-set DP-1 0.65 | brightness-set * 40%
nightlight-toggle | nightlight-force-toggle
wifi-toggle | wifi-status | bluetooth-toggle | bluetooth-status
caffeine-toggle | power-cycle | power-set balanced | dpms-off | dpms-on
```
**Media / theme / wallpaper**
```
media toggle | next | previous | play | stop
theme-mode-toggle | theme-mode-set dark|light|auto | theme-mode-get
color-scheme-get | color-scheme-set custom Peche | color-scheme-set wallpaper m3-content
templates-apply
wallpaper-next | wallpaper-random | wallpaper-set <path> | wallpaper-set DP-1 <path>
```
**Session / shell / notifications**
```
session lock | suspend | lock-and-suspend | logout | reboot | shutdown
status | config-reload | log-level-set <debug|info|warn|error>
notification-dnd-toggle | notification-dnd-status
notification-show "Build done" "All tests passed"
notification-clear-active | notification-clear-history
screenshot-region | screenshot-fullscreen [pick|all|<connector>]
```

---

## 12. App theming (templates) — `[theme.templates]`

Noctalia writes the palette into other apps' configs on every theme change.

```toml
[theme.templates]
enable_builtin_templates   = true
builtin_ids   = ["kitty", "gtk3", "gtk4", "qt", "kcolorscheme", "btop"]
enable_community_templates = true
community_ids = ["zen-browser", "pywalfox"]
```
**Built-in ids:** cava, hyprland, labwc, mango, niri, scroll, sway, emacs, helix, btop, gtk3, gtk4,
kcolorscheme, qt, alacritty, foot, ghostty, kitty, starship, wezterm.
**Community ids:** pi-agent, spicetify, tauon, pywalfox, zen-browser, neovim, obsidian, vscode, zed,
fuzzel, rofi, vicinae, walker, discord, papirus-icons, steam, telegram, yazi, zathura, snappy-switcher, hyprtoolkit.
List live: `noctalia theme --list-templates`. (All the user's old v4 templates — kitty, gtk, qt, kcolorscheme, btop, zen, pywalfox — exist.)
User templates: `[theme.templates.user.<id>]` with `input_path`, `output_path`, `post_hook`.
Community templates cached in `~/.cache/noctalia/community-templates/`. CLI: `noctalia theme <image> -c templates.toml`.

---

## 13. Plugins

Directory + `plugin.toml` + Luau scripts. Provide bar/desktop widgets, panels, CC shortcuts, launcher providers, services.
Two default git sources (protected): **official** `noctalia-dev/official-plugins`, **community** `noctalia-dev/community-plugins`.
"Installed ≠ enabled."
```
noctalia msg plugins list
noctalia msg plugins enable  noctalia/screen_recorder
noctalia msg plugins disable noctalia/screen_recorder
noctalia msg plugins update  official
noctalia msg plugins source add my-dev path ~/dev/my-plugins
noctalia msg plugin <author/plugin:entry> <target> <event> [payload]   # target: focused|DP-1|all
```
Config: `[plugins] enabled = [...]` + `[[plugins.source]]` (name, kind git|path, location, auto_update).
Local hand-placed plugins: `~/.local/share/noctalia/plugins/<plugin>/`.

---

## 14. Hyprland integration (this machine)

Config = `~/.config/hypr/hyprland.lua` (Lua `hl.*` API). Window class = `dev.noctalia.Noctalia`.
Layer namespaces = `noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)`. Docs don't mention uwsm for Noctalia itself.

```lua
-- autostart
hl.on("hyprland.start", function() hl.exec_cmd("noctalia") end)

-- blur + don't fight Noctalia's own anims
hl.layer_rule({
  name = "noctalia",
  match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd)$" },
  no_anim = true, blur = true, blur_popups = true, ignore_alpha = 0.5,
})

-- float settings window
hl.window_rule({ match = { class = "dev.noctalia.Noctalia" }, float = true, size = { 1080, 920 } })
```
`autostart.lua` + `keybinds.lua` on this machine are already migrated to `noctalia` / `noctalia msg`.

---

## 15. FAQ gotchas
- Setting ignored → GUI `settings.toml` loads last and wins. Inspect it.
- Two copies of a widget share settings → give each its own `[widget.<name>]` with a `type`.
- Monday/Sunday first day → not configurable; follows `LC_TIME` locale.
- UI too big/small → prefer compositor output scaling, then `shell.ui_scale`, `[bar.<name>].scale`, `[widget.<name>].scale`.
- Tray icons missing → `pkill kded6`. Battery → needs UPower. Lock screen → needs PAM `login` service.
- Autostart not managed by Settings → use compositor; `noctalia --daemon` if the compositor expects the command to return.
