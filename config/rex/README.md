# Rex / Kitty configuration

Entry point: `init.lua`; keys: `keys.lua`; Vim copy overlay: `grab.lua` and `grab-nvim.lua`.
Original Lua files: `backups/20261103-kitty/`.

## Apply

Run this on the local Mac with Rex's CLI on PATH:

```sh
rex config check
rex config reload
```

Alternatively open the Rex command palette (Cmd+Shift+P) and choose Reload Config.
These commands reload Lua bindings; terminal palettes are applied separately by the theme selector below.

## Shortcuts

All sequences below start with Ctrl+W, then release it:

- `c`: new tab.
- `t`: new tab, using the source directory when Rex knows it.
- `x`: close only the focused pane when the tab has multiple panes; close the tab when it has just one pane (explicitly counted by `close_pane_or_tab`).
- `Shift+X`: close the entire tab, including all its panes.
- `n` / `p`, Tab / Shift+Tab: next / previous tab.
- `1`…`9`, `0`: tabs 1…10; `r`: rename tab.
- `-`: split below; `\`: split right.
- `h/j/k/l`: focus left/down/up/right; `}` / `{`: next/previous pane.
- `.` / `,`: move pane right/left (directional approximation of Kitty order).
- `z`: window full screen; `f`: float the focused pane; `Shift+Z`: pane zoom.
- `v`: Vim selection overlay, described below.
- Ctrl+R: reload config; Shift+D: diagnostics.
- Ctrl+W: send Ctrl+A, matching the original Kitty binding.

Ctrl+Home balances splits. Ctrl+= / Ctrl+- / Ctrl+0 control font size (Rex’s own increment).
Ctrl+Shift+T splits below. Ctrl+Shift+/ opens Find. Cmd+Enter’s automatic split is disabled.
Use native Cmd+V to paste.

## Vim copy overlay

Ctrl+W then `v` captures the focused terminal’s text and opens isolated Neovim in a floating layer. Requires local Rex, Neovim on the user's login-shell PATH, and macOS `pbcopy`. Capture uses Rex's native API, including chunked reads for long scrollback. The overlay loads the user's default login shell to find `nvim`, so Rex and Neovim installation paths do not need to be hardcoded.

- `h/j/k/l`, `w/b`, `0/$`, `gg/G`, Ctrl+U / Ctrl+D: move.
- `v`: character selection; `V`: line selection; Ctrl+V: block selection.
- `y`: yank to the macOS clipboard and close; Enter also copies a visual selection.
- `q`: cancel in normal mode; Escape returns from visual to normal mode.
- Starts at the bottom of the captured buffer, rather than Kitty’s exact cursor/viewport.
- Plain text snapshot; terminal colors and live updates are not preserved. Wrapped terminal lines are joined.
- The temporary capture has mktemp’s private permissions and is deleted after Neovim loads it. If Neovim fails to start, a `rex-grab.*` file may remain in the macOS temporary directory.
- This setup targets local terminals on macOS; remote servers and other operating systems need their own clipboard integration.

## Appearance

Confirmed/set in Rex Settings: ZedMono Nerd Font Mono 14pt (already selected), ligatures off, Option sends Alt, dark appearance, left sidebar tabs, pane headers hidden, padding 8pt on both axes, cyan active pane border, inactive pane fading off.

Themes are managed in `themes/rex/<name>.ghostty` and copied to the ignored `config/rex/theme.ghostty`:

```sh
./shell/scripts/theme-selector set solarized_osaka
```

The selector imports and selects that file through `client.theme.import` for running local Mac clients. Enable **Remote Control** in Rex Settings (Server > Client Info in current docs). Without it, files are still updated but automatic application is refused; import `~/.config/rex/theme.ghostty` in Settings > Themes > Import Theme instead. When Rex is not running, the selector only updates the file; import it after opening Rex or rerun the selector. `init.lua` does not load this file, and Lua config reload alone does not apply it.

All seven themes share their ANSI palette, cursor and selection colors with the corresponding Kitty theme. The Vim copy overlay reads the same active file on each launch. See [theme maintenance](../../themes/README.md) to add or edit themes. Rex stores its imported theme and other UI preferences internally.

## Differences and omissions

Kitty’s 90% opacity, blur=30, exact scrollback_lines=8000, redraw delays, custom Python tab bar, right-click copying, URL hints, kitty-scrollback plugins, saved session format, rotation, pane selection hints, page scrolling shortcuts, and keyboard resize shortcuts have not been ported. Rex currently exposes different capabilities and storage. The imported palette is exact; window material/transparency is not an exact match.

References:
- https://www.superlogical.com/rex/docs/customize/config
- https://www.superlogical.com/rex/docs/reference/mac-settings
- https://www.superlogical.com/rex/docs/reference/lua
