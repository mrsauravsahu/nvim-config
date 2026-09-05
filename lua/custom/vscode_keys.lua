-- VSCode-style keybindings on the Option/Alt key.
--
-- VSCode uses Cmd/Ctrl for these; on macOS Cmd never reaches the terminal and
-- Ctrl is already spoken for by vim, so Alt is the free modifier. `A-k` mirrors
-- VSCode's `Cmd-K` chord leader, so nothing else may bind bare `A-k`.

local map = vim.keymap.set
local all = { "n", "i", "v" }

local function opts(desc)
  return { silent = true, noremap = true, nowait = true, desc = desc }
end

local function tabufline()
  return require "nvchad.tabufline"
end

-- Buffers (VSCode tabs)
map(all, "<A-w>", function() tabufline().close_buffer() end, opts "Close buffer")
map(all, "<A-Right>", function() tabufline().next() end, opts "Next buffer")
map(all, "<A-Left>", function() tabufline().prev() end, opts "Previous buffer")

-- A-1..A-9 jump to the Nth tab, A-0 to the last one, same as VSCode.
local function goto_nth(n)
  return function()
    local bufs = vim.t.bufs or {}
    local bufnr = (n == 0) and bufs[#bufs] or bufs[n]
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
      tabufline().goto_buf(bufnr)
    end
  end
end

for i = 0, 9 do
  map(all, "<A-" .. i .. ">", goto_nth(i), opts("Go to buffer " .. i))
end

-- Editing (these are the literal VSCode bindings, already on Alt there)
map("n", "<A-Up>", "<cmd>m .-2<cr>==", opts "Move line up")
map("n", "<A-Down>", "<cmd>m .+1<cr>==", opts "Move line down")
map("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", opts "Move line up")
map("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", opts "Move line down")
map("v", "<A-Up>", ":m '<-2<cr>gv=gv", opts "Move selection up")
map("v", "<A-Down>", ":m '>+1<cr>gv=gv", opts "Move selection down")

map("n", "<A-S-Up>", "<cmd>t .-1<cr>", opts "Duplicate line up")
map("n", "<A-S-Down>", "<cmd>t .<cr>", opts "Duplicate line down")
map("v", "<A-S-Down>", ":t '><cr>gv", opts "Duplicate selection down")

map("n", "<A-/>", "gcc", { remap = true, silent = true, desc = "Toggle comment" })
map("v", "<A-/>", "gc", { remap = true, silent = true, desc = "Toggle comment" })
map("i", "<A-/>", "<esc>gcca", { remap = true, silent = true, desc = "Toggle comment" })

map(all, "<A-z>", "<cmd>set wrap!<cr>", opts "Toggle word wrap")

-- Search
map(all, "<A-f>", "<cmd>Telescope current_buffer_fuzzy_find<cr>", opts "Find in file")
map(all, "<A-F>", "<cmd>Telescope live_grep<cr>", opts "Find in files")

-- Language features
map(all, "<A-.>", vim.lsp.buf.code_action, opts "Code action")
map("n", "<A-r>", vim.lsp.buf.rename, opts "Rename symbol")
map(all, "<A-S-o>", "<cmd>Telescope lsp_document_symbols<cr>", opts "Go to symbol")

-- A-k chord leader (VSCode's Cmd-K). Both `<A-k><A-x>` and `<A-k>x` work.
local function chord(key, fn, desc)
  map(all, "<A-k><A-" .. key .. ">", fn, opts(desc))
  map(all, "<A-k>" .. key, fn, opts(desc))
end

chord("w", function() tabufline().closeAllBufs(true) end, "Close all buffers")
chord("s", "<cmd>wa<cr>", "Save all files")
chord("f", "<cmd>Telescope live_grep<cr>", "Find in files")
chord("z", "<cmd>set wrap!<cr>", "Toggle word wrap")
chord("\\", "<cmd>vsplit<cr>", "Split editor right")
