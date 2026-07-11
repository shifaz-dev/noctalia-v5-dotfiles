# My Screenshot Setup (Noctalia v5 + satty)

Set up 2026-07-11. Noctalia does the **capture**; **satty** does the **annotation**. One unified flow.

## Keybinds — `~/.config/hypr/config/keybinds.lua`
| Key | Command | Capture |
|---|---|---|
| `Super + Shift + S` | `noctalia msg screenshot-region` | drag a region |
| `Print` | `noctalia msg screenshot-fullscreen` | focused monitor |
| `Super + Print` | `noctalia msg screenshot-fullscreen pick` | pick a monitor |

(Old grim/slurp/swappy bind and the dead v4 `screen-toolkit` binds Super+P/Super+R were removed.)

## Noctalia capture policy — `~/.local/state/noctalia/settings.toml` → `[shell.screenshot]`
```toml
[shell.screenshot]
confirm_region    = false
directory         = "/home/shifaz/Pictures/Screenshots"
save_to_file      = false     # satty owns the save (no duplicate raw files)
copy_to_clipboard = false     # satty owns the clipboard copy
pipe_to_command   = true
pipe_command      = 'satty -f - -o "$NOCTALIA_SCREENSHOT_PATH" --copy-command wl-copy --early-exit'
```
- Noctalia's built-in has **no annotation editor** — `confirm_region` only holds the region overlay
  open until Enter/Space. Annotation = piping the PNG into satty/swappy via `pipe_command`.
- `$NOCTALIA_SCREENSHOT_PATH` is set by Noctalia per-capture (works even with `save_to_file=false`);
  it resolves to `~/Pictures/Screenshots/screenshot_<timestamp>.png`, so satty's save lands there.
- In satty: annotate → `Ctrl+S` saves, copy action → clipboard (`wl-copy`), then `--early-exit` closes it.
- Swap editors anytime: `pipe_command = 'swappy -f -'` (swappy already saves to ~/Pictures/Screenshots via ~/.config/swappy/config).

## Float satty — `~/.config/hypr/config/windowrules.lua`
satty window class = `com.gabm.satty`. Rule added:
```lua
hl.window_rule({ match = { class = "^(com.gabm.satty)$" }, float = true, center = true, size = "(monitor_w*0.7) (monitor_h*0.8)" })
```
→ satty opens floating, centered, at 70% × 80% of the monitor.

## Tools recap
- `grim` = capture pixels · `slurp` = pick region · `swappy`/`satty` = annotate (using **satty**) · `wf-recorder` = video (unrelated).
- Now grim/slurp are unused for screenshots — Noctalia handles capture + region + freeze.
