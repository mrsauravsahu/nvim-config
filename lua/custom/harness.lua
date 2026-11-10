-- The genai harness `gw` would open, but as a right-hand split inside nvim
-- instead of a separate tmux pane. Toggling hides the window and keeps the
-- session alive, so the conversation survives being put away.

local M = {}

local state = { buf = nil, job = nil }

-- Same source of truth as `gw`: $GW_HARNESS (gw's resolved choice, incl. its
-- `gw <dir> <harness>` override), else $GW_CONFIG, else the hub's
-- .friday/config.json (harnessTemplateCommand, then harness), with {{hub}}
-- expanded the way gw does. Falls back to gw's built-in default.
function M.command()
  if vim.env.GW_HARNESS and vim.env.GW_HARNESS ~= "" then
    return vim.env.GW_HARNESS
  end
  local path = vim.env.GW_CONFIG or vim.fn.expand "~/GenAI-Workspace/.friday/config.json"
  local ok, cfg = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
  end)
  local cmd = ok and type(cfg) == "table" and (cfg.harnessTemplateCommand or cfg.harness) or "claude agents"
  -- <hub>/.friday/config.json -> <hub>
  local hub = vim.fn.shellescape(vim.fn.fnamemodify(path, ":p:h:h"))
  return (cmd:gsub("{{hub}}", function()
    return hub
  end))
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

--- Called by `gw` at startup: once startup (incl. auto-session restore) is
--- done, `:cd` into $GW_CD if gw passed one, then open the harness there and
--- hand focus back to the editor.
function M.gw_start()
  local dir = vim.env.GW_CD
  vim.env.GW_CD = nil -- keep it out of the harness's environment
  vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
      vim.schedule(function()
        if dir and dir ~= "" then
          vim.cmd("cd " .. vim.fn.fnameescape(dir))
        end
        M.toggle()
        vim.cmd "stopinsert"
        vim.cmd "wincmd p"
      end)
    end,
  })
end

return M
