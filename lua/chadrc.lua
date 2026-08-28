-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "catppuccin",

	hl_override = {
    Comment = { italic = true },
		["@comment"] = { italic = true },

		-- Blend window separators into the background so the NvimTree/buffer
		-- border and the rule above the statusline disappear. base46 resolves
		-- these names against the active theme, so it follows theme switches.
		-- All three must share one bg, otherwise the separator column is
		-- tree-coloured beside NvimTree and buffer-coloured below it, which
		-- shows up as a one-cell step at the bottom of the split.
		WinSeparator = { fg = "black", bg = "black" },
		VertSplit = { fg = "black", bg = "black" },
		NvimTreeWinSeparator = { fg = "black", bg = "black" },
	},
}

M.nvdash = { load_on_startup = true }
-- M.ui = {
--       tabufline = {
--          lazyload = false
--      }
-- }

require "custom.init"

return M
