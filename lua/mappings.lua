require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("i", "jj", "<ESC>")

map({"n", "i", "t"}, "<C-\\>", function()
  vim.cmd("NvimTreeToggle")
end, { noremap = true, silent = true })

map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
map({"n", "i", "t"}, "<C-p>", "<cmd> Telescope find_files <cr>", { silent = true, noremap = true, nowait = true, desc = "Open Telescope" })

map({"n", "i", "t"}, "<C-g><C-a>", "<cmd> GpAppend <cr>", { silent = true, noremap = true, nowait = true, desc = "" })
map({"n", "i", "t"}, "<C-g><C-r>", "<cmd> GpRewrite <cr>", { silent = true, noremap = true, nowait = true, desc = "" })
map({"n", "i", "t"}, "<C-g><C-i>", "<cmd> GpChatToggle popup <cr>", { silent = true, noremap = true, nowait = true, desc = "" })

