-- Auto open NvimTree when starting Neovim

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      -- require("nvim-tree.api").tree.open()
      -- Move focus back to previous buffer (or empty buffer)
      -- vim.cmd("wincmd p")
      vim.cmd("set foldlevelstart=99")
      vim.cmd("set foldmethod=indent")

    end
  end,
})

-- require "lsp.init"

-- Enable list mode to show non-printable characters
vim.opt.list = true

-- Define how different whitespace characters are rendered
-- space:· displays regular spaces as middle dots
-- tab:»- displays tabs as » followed by hyphens to fill the space
-- trail:· displays trailing spaces as middle dots
-- nbsp:+ displays non-breaking spaces as plus signs
vim.opt.listchars = {
  space = '·',
  tab = '» ',
  trail = '·',
  nbsp = '+',
  extends = '⟩',
  precedes = '⟨'
}

