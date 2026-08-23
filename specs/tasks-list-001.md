# Neovim Config Evaluation — Tasks List 001

**Base:** NvChad v2.5 + custom plugins (LSP, git, 4 AI tools, markdown preview, etc.)

---

## Critical — Breaks Things

| # | File | Line(s) | Issue |
|---|------|---------|-------|
| 1 | `lua/plugins/init.lua` | 155, 163 | **Typo `commmand`** (triple-m) — ollama agents never register as command-mode agents; only `haiku` uses the correct `command` key |
| 2 | `lua/plugins/init.lua` | 226–227 | **Agent name mismatch** — `default_command_agent = "qwen3.5"` (period) but the agent is defined as `"qwen3-5"` (dash) — gp.nvim errors on every invocation |
| 3 | `lua/configs/lazy.lua` | 45 | **`ftplugin` disabled** in the performance module disable list — this kills all filetype-specific indentation, comment strings, and language settings across every filetype |
| 4 | `lua/configs/lspconfig.lua` | 9 | **Unguarded `vim.env.CLI_CONFIG_ROOT`** — if that env var isn't set (fresh shell, different machine), `vim.fs.joinpath` receives `nil` and hard-crashes LSP loading at startup |

---

## Moderate — Degrades Experience

| # | File | Line(s) | Issue |
|---|------|---------|-------|
| 5 | `lua/mappings.lua` + `lua/plugins/init.lua` | 78 / 5–12 | **`<A-g>` double-mapped AND blocks gp.nvim chords** — mapped in both `mappings.lua` and the plugin `keys` spec; pressing `<A-g>` alone immediately fires `:Git`, making `<A-g><A-a>` / `<A-g><A-r>` etc. unreachable |
| 6 | `lua/plugins/init.lua` | 39, 48, 147 | **3 plugins with `lazy = false`** (gitsigns, model-cmp, gp.nvim) — all load at startup unconditionally; gitsigns can use `BufReadPre`, gp.nvim can load on its commands/keys |
| 7 | `lua/chadrc.lua` | 24 | **Side-effect `require "custom.init"` inside a config-return file** — fires all autocmds and options before plugins are fully initialized |
| 8 | `lua/custom/init.lua` | 13 | **Global `foldmethod=indent`** set unconditionally — conflicts with LSP/treesitter folding, adds noisy fold markers to every file |
| 9 | `lua/plugins/init.lua` | 48 | **`model-cmp.nvim` pinned to `tmp/local-stuff`** — a dev scratch branch that could be deleted or force-pushed anytime |
| 10 | `lua/plugins/init.lua` | 48, 147, 247, 297 | **4 overlapping AI plugins** (gp.nvim, opencode.nvim, model-cmp.nvim, ThePrimeagen/99) — each adds startup cost, autocmds, and virtual text that may visually conflict |

---

## Minor — Polish

| # | File | Line(s) | Issue |
|---|------|---------|-------|
| 11 | `lua/mappings.lua` | 57–69 | All gp.nvim keymaps have `desc = ""` — invisible in which-key |
| 12 | `lua/mappings.lua` | 8 | `jj` → ESC fires on real words; `jk` is the standard that never appears in natural text |
| 13 | `lua/custom/lsp/init.lua` | — | Empty dead file (require is commented out) — remove it |
| 14 | `lua/plugins/init.lua` | 60 | `GEMINI_API_KEY = ""` hardcoded empty string — should be `os.getenv("GEMINI_API_KEY")` like the other keys |
| 15 | `lua/options.lua` | — | Nearly empty — missing `scrolloff`, `undofile`, `updatetime`, `signcolumn = "yes"`, `relativenumber`, `wrap = false` etc. |
| 16 | `tmp/` dir | — | Generated files from ThePrimeagen/99 plugin tracked in git — add `tmp/` to `.gitignore` |
| 17 | `lua/options.lua` + `lua/plugins/init.lua` | 6 / 278 | `autoread = true` set twice (minor redundancy) |
| 18 | `lua/custom/init.lua` | 12 | `vim.cmd("set foldlevelstart=99")` should use `vim.opt.foldlevelstart = 99` |
