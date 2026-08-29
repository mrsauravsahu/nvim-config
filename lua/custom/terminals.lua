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

return M
