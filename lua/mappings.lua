require "nvchad.mappings"

local map = vim.keymap.set
local _99 = require("99")

-- Map semicolon to colon for command mode entry
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Map jk to ESC in insert mode
map("i", "jj", "<ESC>")
-- Map jj to save in insert mode
map("i", "kk", "<cmd>w<cr>")

-- View keymaps
map({ "n", "i", "v" }, "<leader>ks", "<cmd> Telescope keymaps <cr>")

-- Alt + \ and Alt + b focus NvimTree (opening it if needed), or close it when already focused
local function focus_or_close_nvimtree()
  local api = require("nvim-tree.api")
  if vim.bo.filetype == "NvimTree" then
    api.tree.close()
  else
    api.tree.focus()
  end
end

map({"n", "i", "t"}, "<A-\\>", focus_or_close_nvimtree, { noremap = true, silent = true })
map({"n", "i", "t"}, "<A-b>", focus_or_close_nvimtree, { noremap = true, silent = true })

-- Save file
map({ "n", "i", "v" }, "<A-s>", "<cmd> w <cr>")
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Toggle Telescope find_files (close if a picker is open, else open)
local function toggle_telescope(open_fn)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "TelescopePrompt" then
      vim.api.nvim_win_close(win, true)
      return
    end
  end
  open_fn()
end

-- hidden=true so dotfiles (.gitignore, .env, etc) show up; rg hides them by
-- default independent of .gitignore filtering. file_ignore_patterns keeps
-- .git/ internals out since --hidden would otherwise surface them too.
map({"n", "i", "t"}, "<A-p>", function()
  toggle_telescope(function()
    require("telescope.builtin").find_files({ hidden = true, file_ignore_patterns = { "^%.git/" } })
  end)
end, { silent = true, noremap = true, nowait = true, desc = "Toggle Telescope" })

-- Open Telescope with no_ignore=true
map({"n", "i", "t"}, "<A-o>", function()
  toggle_telescope(function()
    require("telescope.builtin").find_files({ hidden = true, no_ignore = true, file_ignore_patterns = { "^%.git/" } })
  end)
end, { silent = true, noremap = true, nowait = true, desc = "Toggle Telescope" })

-- Map Ctrl + g and A to append at cursor position in normal, insert, visual, and terminal modes
map({"n", "i", "v", "t"}, "<A-g><A-a>", "<cmd> GpAppend <cr>", { silent = true, noremap = true, nowait = true, desc = "" })

-- Map Ctrl + g and R to rewrite at cursor position in normal, insert, visual modes
map({"n", "i", "v", "t"}, "<A-g><A-r>", "<cmd> GpRewrite <cr>", { silent = true, noremap = true, nowait = true, desc = "" })

-- Map Ctrl + g and I to toggle nvterm chat popup in normal, insert modes
map({"n", "i", "t"}, "<A-g><A-i>", "<cmd> GpChatToggle popup <cr>", { silent = true, noremap = true, nowait = true, desc = "" })

-- Map Ctrl + g and g to tell details about the current GP in normal, insert, visual, and terminal modes
map({"n", "i", "v", "t"}, "<A-g><A-g>", "<cmd> GpAgent <cr>", { silent = true, noremap = true, nowait = true, desc = "" })

-- Map Ctrl + q to capture first completion in insert mode
map({"n", "i", "v", "t"}, "<A-g><A-n>", "<cmd> GpNextAgent <cr>", { silent = true, noremap = true, nowait = true, desc = "" })

-- Map Ctrl + q to capture first completion in insert mode
map({"i"}, "<A-q>", "<cmd> ModelCmp capture first<cr>", { silent = true, noremap = true, nowait = true, desc = "" })

-- Map Ctrl + q to capture first completion in insert mode
map({"n", "i", "v"}, "<A-m>", "<cmd> MarkdownPreview <cr>", { silent = true, noremap = true, nowait = true, desc = "" })

-- Open Git Fugitive with Alt - g
map({"n", "i", "v"}, "<A-g>", "<cmd> Git <cr>", { silent = true, noremap = true, nowait = true, desc = "Open Git Fugitive" })

-- space g a: stage the current file
map("n", "<leader>ga", "<cmd>Git add %<cr>", { silent = true, noremap = true, desc = "Stage current file" })

-- Bottom terminal (logic in custom/terminals.lua). A-h: half, A-j: full --
-- each opens, hides, or switches size; A-k / A-l: grow / shrink by 5 lines.
local terminal_opts = { silent = true, noremap = true, nowait = true }
map({"n", "i", "t"}, "<A-h>", function() require("custom.terminals").toggle_half() end,
  vim.tbl_extend("force", terminal_opts, { desc = "Toggle half horizontal terminal" }))
map({"n", "i", "t"}, "<A-j>", function() require("custom.terminals").toggle_full() end,
  vim.tbl_extend("force", terminal_opts, { desc = "Toggle full horizontal terminal" }))
map({"n", "i", "t"}, "<A-k>", function() require("custom.terminals").resize(5) end,
  vim.tbl_extend("force", terminal_opts, { desc = "Increase terminal height" }))
map({"n", "i", "t"}, "<A-l>", function() require("custom.terminals").resize(-5) end,
  vim.tbl_extend("force", terminal_opts, { desc = "Decrease terminal height" }))

-- A-q: centered Quit/Cancel dialog; Quit closes every terminal, then quits nvim
map(
  {"n", "i", "t"},
  "<A-q>",
  function () require("custom.terminals").close_all() end,
  { silent = true, noremap = true, nowait = true, desc = "Close all terminals and quit" }
)

map(
  {"n", "i", "t"},
  "<A-`>",
  function () require("custom.terminals").toggle() end,
  { silent = true, noremap = true, nowait = true, desc = "Toggle horizontal terminal" }
)

-- GP
map(
  {"n", "i", "t"},
  "<A-g><A-c>",
  function ()
    local gp = require("gp")
    vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
  end,
  { silent = true, noremap = false, nowait = true, desc = "Start new GP chat with current file as context" }
)

map("v", "<leader>9v", function()
  _99.visual()
end)

map("n", "<leader>9x", function()
  _99.stop_all_requests()
end)

map("n", "<leader>9s", function()
  _99.search()
end)

--  opencode
map({ "v", "i", "n", "t" }, "<A-o><A-o>", function() require("opencode").toggle() end,
  { silent = true, noremap = false, nowait = true, desc = "Toggle the nvterm terminal" })

-- A-a: drop where I am into the genai tool in the pane next door (see `gw`).
-- Nothing is submitted -- type the question after it and hit enter yourself.
map({ "n", "i" }, "<A-a>", function() require("custom.agent").cursor() end,
  { silent = true, noremap = true, nowait = true, desc = "Send cursor location to agent pane" })

map("v", "<A-a>", function() require("custom.agent").visual() end,
  { silent = true, noremap = true, nowait = true, desc = "Send selected range to agent pane" })

-- A-c: toggle gw's harness (.friday/config.json) as a right-hand split inside nvim
map({ "n", "i", "t" }, "<A-c>", function() require("custom.harness").toggle() end,
  { silent = true, noremap = true, nowait = true, desc = "Toggle harness split" })

-- C-w h/j/k/l/w/p out of terminal panes (the harness, nvterm). Without these the
-- keys go to the job, and the harness reads C-w as delete-word. A lone C-w still
-- reaches the job after 'timeoutlen'.
for _, key in ipairs { "h", "j", "k", "l", "w", "p" } do
  map("t", "<C-w>" .. key, "<cmd>wincmd " .. key .. "<cr>",
    { silent = true, noremap = true, desc = "Window " .. key .. " from terminal" })
end

-- :bd closes the buffer but keeps the window (logic in custom/buffers.lua), so
-- NvimTree survives closing the last file. A typed `bd` expands to `Bd`.
vim.api.nvim_create_user_command("Bd", function(opts)
  require("custom.buffers").delete(opts.args, opts.bang)
end, { bang = true, nargs = "?", complete = "buffer", desc = "Close buffer, keep window" })
vim.cmd [[cnoreabbrev <expr> bd getcmdtype() == ':' && getcmdline() == 'bd' ? 'Bd' : 'bd']]
