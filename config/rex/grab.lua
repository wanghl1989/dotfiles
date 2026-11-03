-- Local macOS copy mode using Rex capture + an isolated Neovim overlay.
local cli = "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex"
local config_dir = os.getenv("HOME") .. "/.config/rex"
rex.action{
  name = "kitty_grab",
  title = "Select and Copy Terminal Text (Vim)",
  description = "h/j/k/l move; v/V/Ctrl+V select; y copies and closes; q cancels",
  run = function(ctx)
    assert(ctx.session_id and ctx.block_id, "Focus a terminal first")
    local capture, err = rex.exec({ cli, "capture", "-s", ctx.session_id,
      "-b", ctx.block_id, "--trim", "--unwrap" }, { timeout = 10 })
    assert(capture and capture.ok, err or (capture and capture.stderr) or "Capture failed")
    local tmp, tmp_err = rex.exec({ "/usr/bin/mktemp", "-t", "rex-grab" })
    assert(tmp and tmp.ok, tmp_err or "Cannot create copy buffer")
    local path = tmp.stdout:gsub("%s+$", "")
    local file = assert(io.open(path, "wb"))
    file:write(capture.stdout)
    file:close()
    local result, layer_err = rex.session.new_layer{
      bounds = { 0.01, 0.01, 0.98, 0.98 }, focus = true,
      layout = rex.layout.block{
        flavor = "com.superlogical.terminal.shell",
        options = { shell = "none", command = {
          "nvim", "-u", config_dir .. "/grab-nvim.lua",
          "-i", "NONE", "-n", "--", path,
        } },
      },
    }
    if not result then os.remove(path); error(layer_err or "Cannot open copy overlay") end
  end,
}
rex.bind("ctrl+w>v", "kitty_grab")
