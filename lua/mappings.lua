require "nvchad.mappings"

local map = vim.keymap.set

-- Map semicolon to colon for command mode entry
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Map jk and jj to ESC in insert mode
map("i", "jk", "<ESC>")
map("i", "jj", "<ESC>")

-- Toggle NvimTree with Ctrl + \
map({"n", "i", "t"}, "<C-\\>", function()
  vim.cmd("NvimTreeToggle")
end, { noremap = true, silent = true })

-- Save file
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
-- Open Telescope
map({"n", "i", "t"}, "<C-p>", "<cmd> Telescope find_files <cr>",
  { silent = true, noremap = true, nowait = true, desc = "Open Telescope" })
-- Open Telescope with no_ignore=true
map({"n", "i", "t"}, "<C-o>", "<cmd> Telescope find_files no_ignore=true<cr>",
  { silent = true, noremap = true, nowait = true, desc = "Open Telescope" })
-- Map Ctrl + g and A to append at cursor position in normal, insert, visual, and terminal modes
map({"n", "i", "v", "t"}, "<C-g><C-a>", "<cmd> GpAppend <cr>", { silent = true, noremap = true, nowait = true, desc = "" })
-- Map Ctrl + g and R to rewrite at cursor position in normal, insert, visual modes
map({"n", "i", "v", "t"}, "<C-g><C-r>", "<cmd> GpRewrite <cr>", { silent = true, noremap = true, nowait = true, desc = "" })
-- Map Ctrl + g and I to toggle nvterm chat popup in normal, insert modes
map({"n", "i", "t"}, "<C-g><C-i>", "<cmd> GpChatToggle popup <cr>", { silent = true, noremap = true, nowait = true, desc = "" })
-- Map Ctrl + g and g to tell details about the current GP in normal, insert, visual, and terminal modes
map({"n", "i", "v", "t"}, "<C-g><C-g>", "<cmd> GpAgent <cr>", { silent = true, noremap = true, nowait = true, desc = "" })
-- Map Ctrl + q to capture first completion in insert mode
map({"n", "i", "v", "t"}, "<C-g><C-n>", "<cmd> GpNextAgent <cr>", { silent = true, noremap = true, nowait = true, desc = "" })
-- Map Ctrl + q to capture first completion in insert mode
map({"i"}, "<C-q>", "<cmd> ModelCmp capture first<cr>", { silent = true, noremap = true, nowait = true, desc = "" })
-- Toggle nvterm terminal with Alt + j
map(
  {"n", "i", "t"},
  "<A-j>",
  function () require("nvterm.terminal").toggle('horizontal', { focus = true }) end,
  { silent = true, noremap = false, nowait = true, desc = "Toggle the nvterm terminal" }
)

-- Toggle nvterm terminal with Alt + j
map(
  {"n", "i", "t"},
  "<C-g><C-c>",
  function ()
    local gp = require("gp")
    vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
  end,
  { silent = true, noremap = false, nowait = true, desc = "Start new GP chat with current file as context" }
)

