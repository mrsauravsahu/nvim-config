-- Statusline modelled on https://github.com/mcauley-penney/nvim
-- Layout: project › path  branch ↑ahead ↓behind   ...   diagnostics  ≡ lines  ▄▄
--
-- Every component reads from the last *real* file buffer rather than the
-- focused one, so entering a sidebar (NvimTree, nvdash, help, terminal…)
-- leaves the bar showing the file you were actually editing.
local M = {}

local api, fn, bo = vim.api, vim.fn, vim.bo

-- target buffer tracking ------------------------------------------
local last = { buf = nil, win = nil }

local function is_real(buf)
  return buf
    and api.nvim_buf_is_valid(buf)
    and bo[buf].buftype == ""
    and api.nvim_buf_get_name(buf) ~= ""
end

api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter" }, {
  desc = "Remember the last real file buffer for the statusline",
  callback = function(ev)
    if is_real(ev.buf) then last.buf, last.win = ev.buf, api.nvim_get_current_win() end
  end,
})

--- The buffer the statusline should describe: the current one when it is a
--- real file, otherwise the last real file we saw.
local function target_buf()
  local cur = api.nvim_get_current_buf()
  if is_real(cur) then return cur end
  if is_real(last.buf) then return last.buf end
  return cur
end

--- The window displaying `buf`, preferring the current one.
local function target_win(buf)
  local cur = api.nvim_get_current_win()
  if api.nvim_win_get_buf(cur) == buf then return cur end
  if last.win and api.nvim_win_is_valid(last.win) then
    if api.nvim_win_get_buf(last.win) == buf then return last.win end
  end

  for _, win in ipairs(api.nvim_list_wins()) do
    if api.nvim_win_get_buf(win) == buf then return win end
  end
  return nil
end

-- git -------------------------------------------------------------
-- `git status --porcelain=v2 --branch` reports branch and divergence in one
-- shot. Cached per repo root; refreshed on write / focus (autocmd below).
local git_cache = {}
local root_cache = {}

local function repo_root(buf)
  local name = api.nvim_buf_get_name(buf)
  if name == "" then return nil end

  local cached = root_cache[name]
  if cached ~= nil then return cached or nil end

  local root = vim.fs.root(name, { ".git" })
  root_cache[name] = root or false
  return root
end

local function git_state(buf)
  local root = repo_root(buf)
  if not root then return nil end
  if git_cache[root] then return git_cache[root] end

  local job = vim
    .system(
      { "git", "-C", root, "status", "--porcelain=v2", "--branch" },
      { text = true }
    )
    :wait()

  if job.code ~= 0 then return nil end

  local state = {
    head = job.stdout:match("# branch%.head (%S+)"),
    ahead = job.stdout:match("# branch%.ab %+(%d+)"),
    behind = job.stdout:match("# branch%.ab %+%d+ %-(%d+)"),
  }

  git_cache[root] = state
  return state
end

api.nvim_create_autocmd({ "BufWritePost", "FocusGained" }, {
  desc = "Refresh statusline git info",
  callback = function() git_cache = {} end,
})

local function branch()
  local state = git_state(target_buf())
  if not state or not state.head then return "" end
  return " " .. state.head
end

local function divergence()
  local state = git_state(target_buf())
  if not state or not state.ahead then return "" end
  return string.format("↑%s ↓%s", state.ahead, state.behind or 0)
end

-- project / path --------------------------------------------------
local function project()
  local buf = target_buf()
  local root = repo_root(buf)
  local name = root and vim.fs.basename(root) or vim.fs.basename(fn.getcwd())

  return "  " .. name .. " ›"
end

--- Returns the devicon glyph and its highlight group for the target buffer.
local function file_icon_parts()
  local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
  if not devicons_ok then return nil, nil end

  local name = fn.fnamemodify(api.nvim_buf_get_name(target_buf()), ":t")
  return devicons.get_icon(name, fn.fnamemodify(name, ":e"), { default = true })
end

local function file_icon()
  local icon = file_icon_parts()
  return icon or ""
end

--- Colour the icon with the fg of its own DevIcon* group.
local function file_icon_color()
  local _, hl = file_icon_parts()
  if not hl then return nil end

  local group = api.nvim_get_hl(0, { name = hl, link = false })
  return group and group.fg and { fg = string.format("#%06x", group.fg) } or nil
end

local function filename()
  local buf = target_buf()
  local name = api.nvim_buf_get_name(buf)
  if name == "" then return "[No Name]" end

  local root = repo_root(buf)
  local path = root and fn.fnamemodify(name, ":.") or fn.fnamemodify(name, ":t")

  if root then
    -- make the path relative to the repo root, not the cwd
    path = name:sub(#root + 2)
    if path == "" then path = fn.fnamemodify(name, ":t") end
  end

  if bo[buf].modified then path = path .. " •" end
  if bo[buf].readonly then path = path .. " " end

  return path
end

-- diagnostics -----------------------------------------------------
local function diag_count(severity)
  local counts = vim.diagnostic.count(target_buf())
  return counts[severity] or 0
end

local function diagnostics()
  local buf = target_buf()
  if #vim.lsp.get_clients({ bufnr = buf }) == 0 then return "" end

  local err = diag_count(vim.diagnostic.severity.ERROR)
  local warn = diag_count(vim.diagnostic.severity.WARN)
  if err == 0 and warn == 0 then return "" end

  return string.format(" %d  %d", err, warn)
end

-- line count ------------------------------------------------------
local function group_number(num)
  if num < 1000 then return tostring(num) end
  return (
    tostring(num):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
  )
end

local function lines()
  return "≡ " .. group_number(api.nvim_buf_line_count(target_buf())) .. " lines"
end

-- scrollbar -------------------------------------------------------
local sbar = { "▔", "🮂", "🬂", "🮃", "▀", "▄", "▃", "🬭", "▂", "▁" }

local function scrollbar()
  local buf = target_buf()
  local win = target_win(buf)
  if not win then return "" end

  local cur = api.nvim_win_get_cursor(win)[1]
  local total = api.nvim_buf_line_count(buf)
  local idx = math.floor((cur - 1) / total * #sbar) + 1

  return string.rep(sbar[math.min(idx, #sbar)], 2)
end

-- theme -----------------------------------------------------------
-- `theme = "auto"` guesses from generic hl groups and clashes with base46,
-- so build the palette straight from the active NvChad theme instead.
local ok, base46 = pcall(require, "base46")
local palette = ok and base46.get_theme_tb("base_30") or {}

local function theme()
  if not ok then return "auto" end

  local c = palette
  local flat = { a = { bg = c.statusline_bg, fg = c.white } }

  flat.b = { bg = c.statusline_bg, fg = c.blue }
  flat.c = { bg = c.statusline_bg, fg = c.light_grey or c.grey_fg or c.white }
  flat.x, flat.y, flat.z =
    flat.c, flat.c, { bg = c.statusline_bg, fg = c.green }

  return {
    normal = flat,
    insert = flat,
    visual = flat,
    replace = flat,
    command = flat,
    terminal = flat,
    inactive = flat,
  }
end

M.opts = {
  options = {
    theme = theme(),
    globalstatus = true,
    icons_enabled = true,
    component_separators = "",
    section_separators = "",
    -- NB: do NOT disable filetypes for the statusline. With
    -- globalstatus = true, focusing a disabled filetype blanks the *global*
    -- bar and it renders as a black strip.
    disabled_filetypes = { winbar = { "NvimTree", "nvdash" } },
  },
  sections = {
    lualine_a = {},
    lualine_b = {
      { project, color = { fg = palette.blue }, padding = { left = 1, right = 0 } },
    },
    lualine_c = {
      { file_icon, color = file_icon_color, padding = { left = 1, right = 0 } },
      { filename, color = { fg = palette.white }, padding = { left = 1, right = 1 } },
      { branch, color = { fg = palette.green } },
      { divergence, color = { fg = palette.yellow }, padding = { left = 0, right = 1 } },
    },
    lualine_x = {
      { diagnostics, color = { fg = palette.red } },
    },
    lualine_y = { lines },
    lualine_z = { { scrollbar, padding = { left = 1, right = 1 } } },
  },
  -- The bar is global and always describes the last real file, so the
  -- inactive variant is never meaningfully different.
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  extensions = {},
}

return M
