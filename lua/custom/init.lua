-- Auto open NvimTree when starting Neovim
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      require("nvim-tree.api").tree.open()

      -- Move focus back to previous buffer (or empty buffer)
      vim.cmd("wincmd p")
    end
  end,
})

