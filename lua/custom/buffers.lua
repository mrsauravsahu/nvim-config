-- :bd that closes the buffer, never the window. Plain :bd closes every window
-- showing the buffer, so with NvimTree open the last file's window goes and the
-- tree is left alone; run from the tree it deletes the tree itself. Here the
-- target is always a file buffer and its windows switch to another file (or an
-- empty buffer) first. NvDash then takes over when it was the last file (see
-- autocmds.lua).

local M = {}

local function is_file(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted and vim.bo[buf].buftype == ""
end

local function listed_files(except)
  return vim.tbl_filter(function(buf)
    return buf ~= except and is_file(buf)
  end, vim.api.nvim_list_bufs())
end

-- From the tree or a terminal, act on the file you were last in.
local function target_buf(arg)
  if arg and arg ~= "" then
    return vim.fn.bufnr(tonumber(arg) or arg)
  end
  local cur = vim.api.nvim_get_current_buf()
  if is_file(cur) then
    return cur
  end
  local alt = vim.fn.bufnr "#"
  if alt > 0 and is_file(alt) then
    return alt
  end
  return listed_files()[1] or -1
end

function M.delete(arg, force)
  local buf = target_buf(arg)
  if buf <= 0 or not vim.api.nvim_buf_is_valid(buf) then
    vim.notify("No file buffer to close", vim.log.levels.WARN)
    return
  end
  if vim.bo[buf].modified and not force then
    vim.notify("No write since last change (add ! to override)", vim.log.levels.ERROR)
    return
  end

  local alt = vim.fn.bufnr "#"
  local others = listed_files(buf)
  local replacement = (alt ~= buf and is_file(alt)) and alt or others[#others]

  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    vim.api.nvim_win_call(win, function()
      if replacement then
        vim.api.nvim_win_set_buf(win, replacement)
      else
        vim.cmd "enew"
      end
    end)
  end

  vim.cmd((force and "bdelete! " or "bdelete ") .. buf)
end

return M
