-- The genai harness `gw` would open, but as a right-hand split inside nvim
-- instead of a separate tmux pane. Toggling hides the window and keeps the
-- session alive, so the conversation survives being put away.

local M = {}

local state = { buf = nil, job = nil }

-- Same source of truth as `gw`: $GW_CONFIG, else the hub's .friday/config.json.
-- Falls back to gw's built-in default when the file or key is missing.
function M.command()
  local path = vim.env.GW_CONFIG or vim.fn.expand "~/GenAI-Workspace/.friday/config.json"
  local ok, cfg = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
  end)
  return ok and type(cfg) == "table" and cfg.harness or "claude agents"
end

local function find_win()
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    return nil
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_buf(win) == state.buf then
      return win
    end
  end
end

-- Full-height column on the far right, 30% wide -- the same split `gw` makes.
local function open_win()
  vim.cmd "botright vsplit"
  vim.api.nvim_win_set_width(0, math.floor(vim.o.columns * 0.3))
  vim.wo.winfixwidth = true
end

local function start()
  open_win()
  -- A fresh buffer: the split still shows the file we came from, and
  -- `term = true` turns whatever buffer is current into the terminal.
  state.buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, state.buf)
  -- Interactive zsh so asdf/PATH match the user's shell. TMUX_NESTING_LEVEL=2
  -- tells .zshrc's auto_tmux not to wrap this in a nested `tmux -L vim`, which
  -- would swallow the command.
  state.job = vim.fn.jobstart({ "zsh", "-ic", M.command() }, {
    term = true,
    cwd = vim.fn.getcwd(),
    env = { TMUX_NESTING_LEVEL = "2" },
    on_exit = function()
      state.job = nil
    end,
  })
  vim.bo[state.buf].buflisted = false
end

--- Show, focus or hide the harness split.
function M.toggle()
  local win = find_win()
  if win and win == vim.api.nvim_get_current_win() then
    vim.api.nvim_win_close(win, false)
    return
  end

  if win then
    vim.api.nvim_set_current_win(win)
  elseif state.job then
    open_win()
    vim.api.nvim_win_set_buf(0, state.buf)
  else
    start()
  end
  vim.cmd "startinsert"
end

--- Type text into the harness prompt without submitting. Returns false when
--- no harness is running in this nvim.
function M.send(text)
  if not state.job then
    return false
  end
  vim.api.nvim_chan_send(state.job, text)
  if not find_win() then
    open_win()
    vim.api.nvim_win_set_buf(0, state.buf)
  end
  vim.api.nvim_set_current_win(find_win())
  vim.cmd "startinsert"
  return true
end

return M
