-- Local macOS copy mode using Rex capture + an isolated Neovim overlay.
local config_dir = os.getenv("HOME") .. "/.config/rex"
local function capture_text(ctx)
  local capture, err = rex.block.call("com.superlogical.terminal", "format", {
    session_id = ctx.session_id, block_id = ctx.block_id,
    format = "text", trim = true, unwrap = true, max_bytes = 49152,
  })
  assert(capture, err or "Capture failed")
  local parts, offset = { capture.content }, #capture.content
  if capture.id then
    while true do
      local part, read_err = rex.block.call("com.superlogical.terminal", "blob_read", {
        session_id = ctx.session_id, block_id = ctx.block_id,
        id = capture.id, offset = offset, max_bytes = 49152,
      })
      assert(part, read_err or "Cannot read remaining capture")
      parts[#parts + 1] = part.data
      offset = offset + #part.data
      if part.eof then break end
      assert(#part.data > 0, "Capture stopped before reaching the end")
    end
  end
  return table.concat(parts)
end

rex.action{
  name = "kitty_grab",
  title = "Select and Copy Terminal Text (Vim)",
  description = "h/j/k/l move; v/V/Ctrl+V select; y copies and closes; q cancels",
  run = function(ctx)
    assert(ctx.session_id and ctx.block_id, "Focus a terminal first")
    local capture = capture_text(ctx)
    local tmp, tmp_err = rex.exec({ "/usr/bin/mktemp", "-t", "rex-grab" })
    assert(tmp and tmp.ok, tmp_err or "Cannot create copy buffer")
    local path = tmp.stdout:gsub("%s+$", "")
    local file = assert(io.open(path, "wb"))
    file:write(capture)
    file:close()
    local result, layer_err = rex.session.new_layer{
      bounds = { 0.01, 0.01, 0.98, 0.98 }, focus = true,
      layout = rex.layout.block{
        flavor = "com.superlogical.terminal.shell",
        -- The default login shell loads the user's PATH before resolving nvim.
        options = { command = {
          "nvim", "-u", config_dir .. "/grab-nvim.lua",
          "-i", "NONE", "-n", "--", path,
        } },
      },
    }
    if not result then os.remove(path); error(layer_err or "Cannot open copy overlay") end
  end,
}
rex.bind("ctrl+w>v", "kitty_grab")
