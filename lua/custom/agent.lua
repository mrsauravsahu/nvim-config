-- Send cursor / selection context to the genai tool running in the neighbouring
-- tmux pane -- the layout `gw` creates (nvim left, agent right, same window).
--
-- Harness-agnostic on purpose: it types plain text into whatever is sitting at
-- that pane's prompt (claude, opencode, aider, a plain shell), so it needs no
-- plugin, MCP server or API on the other end. It deliberately does NOT press
-- Enter -- the context lands in the prompt with the cursor after it, and you
-- finish the sentence yourself. Same feel as the ask-AI shortcut in VS Code.

local M = {}

-- gw forces the top-level tmux server; nvim's own nested server is `-L vim`.
local TMUX = { "tmux", "-L", "default" }

local function tmux_cmd(args)
  local cmd = vim.list_extend(vim.deepcopy(TMUX), args)
  local out = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    return nil, vim.trim(out)
  end
  return vim.trim(out)
end

-- The agent pane is simply the other pane in our window. Panes are listed with
-- their x offset, so taking the rightmost one that isn't us finds the pane `gw`
-- split off to the right, and still does something sane if that layout changes.
local function agent_pane()
  local me = vim.env.TMUX_PANE
  if not me or me == "" then
    return nil, "not inside tmux"
  end
  local out, err = tmux_cmd { "list-panes", "-t", me, "-F", "#{pane_left} #{pane_id}" }
  if not out then
    return nil, err
  end

  local panes = {}
  for line in out:gmatch "[^\n]+" do
    local left, id = line:match "^(%d+) (%%%d+)$"
    if id and id ~= me then
      table.insert(panes, { left = tonumber(left), id = id })
    end
  end
  if #panes == 0 then
    return nil, "no other pane in this window -- is the agent open? (run `gw`)"
  end

  table.sort(panes, function(a, b)
    return a.left > b.left
  end)
  return panes[1].id
end

-- Path relative to cwd: `gw` starts nvim and the agent in the same directory,
-- so a relative path is what the agent can act on directly.
local function relative_path()
  local path = vim.fn.expand "%:."
  if path == "" then
    return nil, "current buffer has no file"
  end
  return path
end

local function send(context)
  local pane, err = agent_pane()
  if not pane then
    vim.notify("agent: " .. err, vim.log.levels.WARN)
    return
  end

  -- -l sends the string literally, so no character is read as a key name. No
  -- Enter is sent: the user types their question and submits it themselves.
  local _, send_err = tmux_cmd { "send-keys", "-t", pane, "-l", context .. " " }
  if send_err then
    vim.notify("agent: " .. send_err, vim.log.levels.WARN)
    return
  end
  tmux_cmd { "select-pane", "-t", pane }
end

--- Send the current file and cursor line.
function M.cursor()
  local path, err = relative_path()
  if not path then
    vim.notify("agent: " .. err, vim.log.levels.WARN)
    return
  end
  send(string.format("%s (line %d)", path, vim.fn.line "."))
end

--- Send the current file and the visually selected line range.
function M.visual()
  local path, err = relative_path()
  if not path then
    vim.notify("agent: " .. err, vim.log.levels.WARN)
    return
  end

  -- `<` / `>` still hold the previous selection while the mapping runs, so read
  -- the live one instead: `v` is the anchor, `.` the cursor.
  local first, last = vim.fn.getpos("v")[2], vim.fn.line "."
  if first > last then
    first, last = last, first
  end

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)

  if first == last then
    send(string.format("%s (line %d)", path, first))
  else
    send(string.format("%s (lines %d-%d)", path, first, last))
  end
end

return M
