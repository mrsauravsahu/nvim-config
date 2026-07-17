require "nvchad.mappings"

local map = vim.keymap.set
local _99 = require("99")

-- Map semicolon to colon for command mode entry
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Map jk to ESC in insert mode
map("i", "jj", "<ESC>")
-- Map jj to save in insert mode
map("i", "kk", "<cmd>w<cr>")

-- Toggle NvimTree with Alt + \
map({"n", "i", "t"}, "<A-\\>", function()
  vim.cmd("NvimTreeToggle")
end, { noremap = true, silent = true })

-- Toggle NvimTree with Alt + b
map({"n", "i", "t"}, "<A-b>", function()
  vim.cmd("NvimTreeToggle")
end, { noremap = true, silent = true })

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

-- "half" | "full" | nil
local term_size_state = nil

local function find_term_win()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "terminal" then
      return win
    end
  end
end

local function term_looks_full(win)
  local usable = vim.o.lines - vim.o.cmdheight - 1
  return vim.api.nvim_win_get_height(win) > math.floor(usable * 0.6)
end

-- A-h: open half terminal; if half → hide; if full → shrink to half
map(
  {"n", "i", "t"},
  "<A-h>",
  function ()
    local win = find_term_win()
    if not win then
      require("nvterm.terminal").toggle "horizontal"
      vim.cmd "wincmd ="
      term_size_state = "half"
    elseif term_size_state == "full" or term_looks_full(win) then
      local half = math.floor((vim.o.lines - vim.o.cmdheight - 1) * 0.5)
      vim.api.nvim_win_set_height(win, half)
      term_size_state = "half"
    else
      require("nvterm.terminal").toggle "horizontal"
      term_size_state = nil
    end
  end,
  { silent = true, noremap = true, nowait = true, desc = "Toggle half horizontal terminal" }
)

-- A-j: open full terminal; if full → hide; if half → expand to full
map(
  {"n", "i", "t"},
  "<A-j>",
  function ()
    local win = find_term_win()
    if not win then
      require("nvterm.terminal").toggle "horizontal"
      vim.cmd "wincmd _"
      term_size_state = "full"
    elseif term_size_state == "half" or not term_looks_full(win) then
      vim.cmd "wincmd _"
      term_size_state = "full"
    else
      require("nvterm.terminal").toggle "horizontal"
      term_size_state = nil
    end
  end,
  { silent = true, noremap = true, nowait = true, desc = "Toggle full horizontal terminal" }
)

-- A-k: increase terminal height by 5 lines
map(
  {"n", "i", "t"},
  "<A-k>",
  function ()
    local win = find_term_win()
    if win then
      local height = vim.api.nvim_win_get_height(win)
      vim.api.nvim_win_set_height(win, height + 5)
    end
  end,
  { silent = true, noremap = true, nowait = true, desc = "Increase terminal height" }
)

-- A-l: decrease terminal height by 5 lines
map(
  {"n", "i", "t"},
  "<A-l>",
  function ()
    local win = find_term_win()
    if win then
      local height = vim.api.nvim_win_get_height(win)
      vim.api.nvim_win_set_height(win, math.max(5, height - 5))
    end
  end,
  { silent = true, noremap = true, nowait = true, desc = "Decrease terminal height" }
)

map(
  {"n", "i", "t"},
  "<A-`>",
  function () require("nvterm.terminal").toggle "horizontal" end,
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

