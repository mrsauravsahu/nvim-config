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

-- :bd on the last file leaves an empty [No Name] buffer; show NvDash there
-- instead. Scheduled so the deleted buffer is gone from the list by then.
vim.api.nvim_create_autocmd("BufDelete", {
  desc = "Open NvDash when the last file buffer is closed",
  callback = function(ev)
    if not vim.bo[ev.buf].buflisted or vim.api.nvim_buf_get_name(ev.buf) == "" then
      return
    end
    vim.schedule(function()
      if vim.v.exiting ~= vim.NIL then
        return
      end
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buflisted and vim.api.nvim_buf_get_name(buf) ~= "" then
          return
        end
      end
      require("custom.terminals").focus_editor_win()
      if vim.bo.buftype ~= "terminal" then
        require("nvchad.nvdash").open()
      end
    end)
  end,
})

vim.api.nvim_create_autocmd("QuitPre", {
  desc = "Close nvterm terminals before quitting",
  callback = function()
    require("custom.terminals").close_all { silent = true }
  end,
})
