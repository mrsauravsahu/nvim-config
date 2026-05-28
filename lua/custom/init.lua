-- Auto open NvimTree when starting Neovim
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd("ModelCmp virtualtext enable")

    local auto_session = require("auto-session")
    local will_restore = auto_session.session_exists_for_cwd and auto_session.session_exists_for_cwd()
    if not will_restore then
      require("nvim-tree.api").tree.open()
    end

    vim.cmd("wincmd p")
    vim.cmd("set foldlevelstart=99")
    vim.cmd("set foldmethod=indent")
  end,
})

vim.api.nvim_create_user_command("TestVT", function()
  local ns = vim.api.nvim_create_namespace("vt_test")
  vim.api.nvim_buf_set_extmark(0, ns, 0, 0, {
    virt_text = {{" Hello VT 🚀", "Comment"}},
    virt_text_pos = "eol",
  })
end, {})

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

