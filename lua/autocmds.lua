require "nvchad.autocmds"

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd "checktime"
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
})

-- Terminal panes (nvterm, the <A-c> harness, opencode) take the sidebar's
-- darker bg, so with the split rules blanked the editor still reads as the one
-- lighter area. BufWinEnter re-applies it when a hidden terminal is reshown in
-- a fresh window. No cursorline: the shell/harness draws its own cursor.
vim.api.nvim_create_autocmd({ "TermOpen", "BufWinEnter" }, {
  desc = "Style terminal panes",
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "terminal" then
      return
    end
    local win = vim.fn.bufwinid(ev.buf)
    if win == -1 then
      return
    end
    vim.wo[win].winhighlight = "Normal:TermNormal,NormalNC:TermNormal"
    vim.wo[win].cursorline = false
  end,
})

vim.api.nvim_create_autocmd("QuitPre", {
  desc = "Close nvterm terminals before quitting",
  callback = function()
    require("custom.terminals").close_all { silent = true }
  end,
})
