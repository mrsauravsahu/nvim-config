require "nvchad.options"

-- add yours here!

local o = vim.o
o.autoread = true
o.cursorlineopt ='both'

-- Blank the window-separator glyphs themselves, so no rule is drawn between
-- splits (NvimTree/buffer) or above the statusline. Paired with the
-- WinSeparator hl_override in chadrc.lua.
vim.opt.fillchars:append {
  vert = " ",
  horiz = " ",
  horizup = " ",
  horizdown = " ",
  vertleft = " ",
  vertright = " ",
  verthoriz = " ",
}
-- to enable cursorline!
