-- Kitty-style shortcuts. Press Ctrl+W, release, then the next key.
local bind = rex.bind
-- Explicitly close the tab when its last pane is closed.
rex.action{
  name = "close_pane_or_tab",
  title = "Close Pane or Last Pane's Tab",
  run = function(ctx)
    assert(ctx.block_id, "Focus a pane first")
    local view, err = rex.session.view{}
    assert(view, err)
    for _, window in ipairs(view.windows or {}) do
      local count, contains_focus = 0, false
      for _, layer in ipairs(window.layers or {}) do
        for _, block in ipairs(layer.blocks or {}) do
          count = count + 1
          if block.block_id == ctx.block_id then contains_focus = true end
        end
      end
      if contains_focus then
        rex.client.queue(count == 1 and "client.tab.close" or "pane.close")
        return
      end
    end
    error("Focused pane is no longer in a tab")
  end,
}
bind("ctrl+w>c", "session.new")
bind("ctrl+w>t", "client.tab.new")
bind("ctrl+w>shift+x", "client.tab.close")
bind("ctrl+w>x", "close_pane_or_tab")
bind("ctrl+w>n", "client.tab.next")
bind("ctrl+w>p", "client.tab.previous")
bind("ctrl+w>tab", "client.tab.next")
bind("ctrl+w>shift+tab", "client.tab.previous")
bind("ctrl+w>r", "client.tab.rename")
bind("ctrl+w>\\", "pane.split.right")
bind("ctrl+w>shift+\\", "pane.split.right")
bind("ctrl+w>-", "pane.split.down")
bind("ctrl+w>shift+-", "pane.split.down")
bind("ctrl+shift+t", "pane.split.down")
bind("ctrl+w>h", "pane.focus.left")
bind("ctrl+w>j", "pane.focus.down")
bind("ctrl+w>k", "pane.focus.up")
bind("ctrl+w>l", "pane.focus.right")

bind("ctrl+h", "pane.focus.left")
bind("ctrl+j", "pane.focus.down")
bind("ctrl+k", "pane.focus.up")
bind("ctrl+l", "pane.focus.right")

bind("ctrl+w>shift+]", "pane.focus_next")
bind("ctrl+w>shift+[", "pane.focus_previous")
-- Rex exposes directional moves rather than Kitty's forward/backward order.
bind("ctrl+w>.", "pane.move.right")
bind("ctrl+w>,", "pane.move.left")
bind("ctrl+home", "pane.balance")
for n = 1, 9 do
  bind("ctrl+w>" .. n, "client.tab.goto", { index = n })
end
bind("ctrl+w>0", "client.tab.goto", { index = 10 })
bind("ctrl+w>z", "client.window.fullscreen.toggle")
bind("ctrl+w>f", "pane.float")
-- Extra: maximize just the pane.
bind("ctrl+w>shift+z", "pane.zoom")
bind("ctrl+=", "client.font.increase")
bind("ctrl+shift+=", "client.font.increase")
bind("ctrl+-", "client.font.decrease")
bind("ctrl+0", "client.font.reset")
bind("ctrl+shift+/", "client.find.open")
bind("ctrl+w>ctrl+r", "client.config.reload")
bind("ctrl+w>shift+d", "client.diagnostics")
-- Preserve Kitty's deliberate Ctrl+A passthrough.
bind("ctrl+w>ctrl+w", "pane.send_key", { key = "ctrl+a" })
-- Kitty intentionally disables accidental split shortcuts.
rex.unbind("cmd+enter")

rex.mode("resize", { exclusive = true })
rex.bind("ctrl+w>shift+r", "client.mode.enter", { name = "resize" })

rex.bind("resize/left", "pane.resize", { direction = "left" })
rex.bind("resize/right", "pane.resize", { direction = "right" })
rex.bind("resize/up", "pane.resize", { direction = "up" })
rex.bind("resize/down", "pane.resize", { direction = "down" })

-- Hold shift for bigger steps
rex.bind("resize/shift+left", "pane.resize", {
  direction = "left",
  amount = 15,
})
rex.bind("resize/shift+right", "pane.resize", {
  direction = "right",
  amount = 15,
})

rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")
