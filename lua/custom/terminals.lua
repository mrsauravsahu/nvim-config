-- Close every terminal buffer (nvterm's own, plus any stray :terminal), then quit.
--
-- The terminals here run tmux, so deleting a buffer kills the tmux *client*;
-- the tmux server and its sessions survive detached and can be reattached.

local M = {}

local function is_opencode_buf(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return name:lower():find("opencode", 1, true) ~= nil
end

-- nvterm's close_all_terms only reaches terminals whose window is open, so a
-- terminal toggled away with <A-h> would survive it. list_terms() is unfiltered.
local function list_term_bufs()
  local ok, nvterm = pcall(require, "nvterm.terminal")
  local bufs = {}
  local seen = {}

  if ok and nvterm.list_terms then
    for _, term in ipairs(nvterm.list_terms() or {}) do
      if term.buf and vim.api.nvim_buf_is_valid(term.buf) and not is_opencode_buf(term.buf) then
        bufs[#bufs + 1] = term.buf
        seen[term.buf] = true
      end
    end
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      not seen[buf]
      and vim.api.nvim_buf_is_valid(buf)
      and vim.bo[buf].buftype == "terminal"
      and not is_opencode_buf(buf)
    then
      bufs[#bufs + 1] = buf
    end
  end

  return bufs
end

local function close_bufs(bufs)
  for _, buf in ipairs(bufs) do
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
  end
end

-- A centered two-button dialog. Quit is selected by default, so <CR> quits.
-- Returns nothing; calls on_choice(true) for Quit, on_choice(false) for Cancel.
local function dialog(message, on_choice)
  local buttons = { "Quit", "Cancel" }
  local selected = 1

  local labels = {}
  for i, b in ipairs(buttons) do
    labels[i] = "  " .. b .. "  "
  end

  local button_line = table.concat(labels, "   ")
  local width = math.max(#message, #button_line) + 4
  local pad = function(s)
    local left = math.floor((width - #s) / 2)
    return string.rep(" ", left) .. s
  end

  local lines = { "", pad(message), "", pad(button_line), "" }
  local button_row = 4 -- 1-indexed line holding the buttons

  -- byte ranges of each button on button_row, for highlighting
  local base = math.floor((width - #button_line) / 2)
  local ranges = {}
  local offset = base
  for i, label in ipairs(labels) do
    ranges[i] = { offset, offset + #label }
    offset = offset + #label + 3
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = #lines,
    row = math.floor((vim.o.lines - #lines) / 2 - 1),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Close terminals ",
    title_pos = "center",
    noautocmd = true,
  })
  vim.wo[win].winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder"
  -- <A-q> is bound in terminal mode too; the dialog's keys are normal-mode.
  vim.cmd "stopinsert"

  local ns = vim.api.nvim_create_namespace "close_terminals_dialog"
  local function render()
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for i, range in ipairs(ranges) do
      vim.api.nvim_buf_add_highlight(
        buf,
        ns,
        i == selected and "Visual" or "Comment",
        button_row - 1,
        range[1],
        range[2]
      )
    end
  end
  render()

  local function finish(choice)
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    on_choice(choice)
  end

  local function keymap(lhs, fn)
    vim.keymap.set("n", lhs, fn, { buffer = buf, nowait = true, silent = true })
  end

  local function move(delta)
    selected = (selected + delta - 1) % #buttons + 1
    render()
  end

  keymap("<CR>", function() finish(selected == 1) end)
  keymap("q", function() finish(true) end)
  keymap("c", function() finish(false) end)
  keymap("<Esc>", function() finish(false) end)
  keymap("h", function() move(-1) end)
  keymap("l", function() move(1) end)
  keymap("<Left>", function() move(-1) end)
  keymap("<Right>", function() move(1) end)
  keymap("<Tab>", function() move(1) end)
  keymap("<S-Tab>", function() move(-1) end)
end

-- opts.silent skips the dialog and quits nothing; the QuitPre autocmd passes it,
-- because a quit can't be cancelled from an autocmd anyway.
-- Returns true when terminals were closed (silent path only).
function M.close_all(opts)
  opts = opts or {}
  local bufs = list_term_bufs()

  if opts.silent then
    if #bufs == 0 then
      return false
    end
    close_bufs(bufs)
    return true
  end

  local word = #bufs == 1 and "terminal" or "terminals"
  local message = #bufs == 0 and "Quit Neovim?"
    or string.format("Close %d %s and quit Neovim?", #bufs, word)

  dialog(message, function(quit)
    if not quit then
      return
    end
    close_bufs(bufs)
    -- `qa` (not `qa!`) so unsaved buffers still get Neovim's own warning.
    vim.cmd "qa"
  end)

  return false
end

-- Sidebars (NvimTree, etc.) are windows too, so a `rightbelow split` taken while
-- the tree is focused would carve the terminal out of the sidebar column. Move
-- focus to a real editor window first so the terminal lands on the right side.
local sidebar_fts = {
  NvimTree = true,
  ["neo-tree"] = true,
  undotree = true,
  Outline = true,
  aerial = true,
}

function M.focus_editor_win()
  local function is_sidebar(win)
    local buf = vim.api.nvim_win_get_buf(win)
    return sidebar_fts[vim.bo[buf].filetype] or vim.api.nvim_win_get_config(win).relative ~= ""
  end

  if not is_sidebar(vim.api.nvim_get_current_win()) then
    return
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if not is_sidebar(win) then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
end

-- The bottom terminal and its sizing keys. Only nvterm's horizontal terminal
-- counts: the harness split (<A-c>) is a terminal too, but it's a full-height
-- column these keys must leave alone.

-- "half" | "full" | nil
local size_state = nil

local function horizontal_term()
  local ok, nvterm = pcall(require, "nvterm.terminal")
  if not ok then
    return nil
  end
  for _, term in ipairs(nvterm.list_terms() or {}) do
    if
      term.type == "horizontal"
      and term.open
      and term.win
      and vim.api.nvim_win_is_valid(term.win)
      and vim.api.nvim_win_get_buf(term.win) == term.buf
    then
      return term
    end
  end
end

local function horizontal_win()
  local term = horizontal_term()
  return term and term.win
end

local function is_float(win)
  return vim.api.nvim_win_get_config(win).relative ~= ""
end

local function usable_height()
  return vim.o.lines - vim.o.cmdheight - 1
end

local function looks_full(win)
  return vim.api.nvim_win_get_height(win) > math.floor(usable_height() * 0.6)
end

--- Show or hide the bottom terminal, landing it under the editor, not the tree.
function M.toggle()
  if not horizontal_win() then
    M.focus_editor_win()
  end
  require("nvterm.terminal").toggle "horizontal"
end

-- Full height is a float, not a maximized split: `wincmd _` still leaves the
-- editor its 'winminheight' line plus a separator row above the terminal. The
-- float covers everything between the tabline and the global statusline, in the
-- split's columns, so the tree stays visible. nvterm's term.win is pointed at
-- it, so nvterm's own hide closes it like the split.
local function float_geometry(col, width)
  local tabline = vim.o.showtabline == 2 or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)
  local top = tabline and 1 or 0
  return {
    relative = "editor",
    row = top,
    col = col,
    width = width,
    height = usable_height() - top,
    zindex = 10, -- under pickers, dialogs and other floats
  }
end

local function maximize(term)
  local split = term.win
  local col = vim.api.nvim_win_get_position(split)[2]
  local float = vim.api.nvim_open_win(term.buf, true, float_geometry(col, vim.api.nvim_win_get_width(split)))
  vim.wo[float].winhighlight = vim.wo[split].winhighlight
  vim.wo[float].cursorline = false
  vim.wo[float].number = false
  vim.wo[float].relativenumber = false
  vim.api.nvim_win_close(split, false)
  term.win = float
  vim.cmd "startinsert"
end

local function open_half()
  M.toggle()
  vim.cmd "wincmd ="
  size_state = "half"
end

--- Open at half height; if half, hide; if full, shrink to half.
function M.toggle_half()
  local term = horizontal_term()
  if not term then
    open_half()
  elseif is_float(term.win) then
    require("nvterm.terminal").hide_term(term)
    open_half()
  elseif size_state == "full" or looks_full(term.win) then
    vim.api.nvim_win_set_height(term.win, math.floor(usable_height() * 0.5))
    size_state = "half"
  else
    M.toggle()
    size_state = nil
  end
end

--- Open at full height; if full, hide; if half, expand to full.
function M.toggle_full()
  local term = horizontal_term()
  if term and is_float(term.win) then
    M.toggle()
    size_state = nil
    return
  end
  if not term then
    M.toggle()
    term = horizontal_term()
  end
  if term then
    maximize(term)
    size_state = "full"
  end
end

-- Leaving the full float for a real window (C-w k/p, a click) would land in an
-- editor hidden under it, so drop back to half height there. Floats (pickers,
-- dialogs) don't count. Resizing the editor refits the float.
local group = vim.api.nvim_create_augroup("custom_full_terminal", { clear = true })

vim.api.nvim_create_autocmd("WinEnter", {
  group = group,
  callback = function()
    local term = horizontal_term()
    local cur = vim.api.nvim_get_current_win()
    if not term or not is_float(term.win) or cur == term.win or is_float(cur) then
      return
    end
    require("nvterm.terminal").hide_term(term)
    vim.schedule(function()
      M.toggle()
      vim.cmd "wincmd ="
      vim.cmd "stopinsert"
      size_state = "half"
      if vim.api.nvim_win_is_valid(cur) then
        vim.api.nvim_set_current_win(cur)
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  callback = function()
    local term = horizontal_term()
    if term and is_float(term.win) then
      local cfg = vim.api.nvim_win_get_config(term.win)
      vim.api.nvim_win_set_config(term.win, float_geometry(cfg.col, math.min(cfg.width, vim.o.columns - cfg.col)))
    end
  end,
})

--- Grow (positive) or shrink (negative) the bottom terminal, never below 5 lines.
function M.resize(delta)
  local win = horizontal_win()
  if win and not is_float(win) then
    vim.api.nvim_win_set_height(win, math.max(5, vim.api.nvim_win_get_height(win) + delta))
  end
end

return M
