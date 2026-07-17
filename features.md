---
title: "Manual: nvim-config"
author: Sahu, S <mrsauravsahu@outlook.com>
---

Personal manual for **@mrsauravsahu/nvim-config**. Goal: use everything that's installed.

Built on **NvChad v2.5** as a plugin: config stays in `lua/`, NvChad updates cleanly underneath.

## At a Glance

Four layers:

- **Core editing**: Treesitter (main branch), LSP, conform, folds, whitespace rendering
- **Workspace**: nvim-tree (right), auto-session, nvterm, telescope + nvim-mapper
- **Git**: fugitive (`<leader>gg`) + gitsigns
- **AI**: model-cmp (inline), gp.nvim (chat/rewrite), opencode (agentic), 99 (prompt-driven)

Rule of thumb: **AI layer has the most unused power.**

## UI & Theme

- **Theme**: `bearded-arc` (change in `lua/chadrc.lua` → `M.base46.theme`)
- **NvDash**: startup dashboard loads automatically
- **Whitespace rendering**: spaces shown as `·`, tabs as `»`, trailing spaces highlighted, line overflow indicators `⟩⟨`
- **Italic comments** via highlight override
- **NvimTree** file explorer on the **right side**, shows dotfiles and git-ignored files
  - Auto-opens on startup if no saved session exists
  - Toggle: `Ctrl+\`, `Alt+\`, or `Alt+b` (works in normal, insert, terminal mode)

## Sessions (auto-session)

Sessions are saved **per working directory** automatically.

- When you open nvim in a project directory, the last session is restored (open files, splits, etc.)
- Terminal windows are closed before saving (they can't be restored cleanly)
- NvimTree is closed before restore and reopened after

## File Finding (Telescope)

| Key | Action |
|-----|--------|
| `Alt+p` | **Toggle** find files (respects .gitignore, shows dotfiles); closes picker if already open |
| `Alt+o` | **Toggle** find files ignoring .gitignore (shows everything, shows dotfiles); closes picker if already open |

Both show dotfiles (`.gitignore`, `.env`, etc) but hide `.git/` internals. Both work from normal, insert, and terminal mode.

NvChad also ships these Telescope mappings by default:
- `<leader>fw`: live grep across project
- `<leader>fb`: find open buffers
- `<leader>fh`: find help tags
- `<leader>fo`: find old/recent files
- `<leader>gc`: git commits
- `<leader>gt`: git status

### Inside a picker

Stock Telescope defaults, work in any picker (find_files, live_grep, buffers, etc).

| Key | Action |
|-----|--------|
| `Ctrl+n` / `Down` | Next result |
| `Ctrl+p` / `Up` | Previous result |
| `Enter` | Open selection in current window |
| `Ctrl+x` | Open in horizontal split |
| `Ctrl+v` | Open in vertical split |
| `Ctrl+t` | Open in new tab |
| `Tab` | Toggle multi-select, move down |
| `Shift+Tab` | Toggle multi-select, move up |
| `Ctrl+u` / `Ctrl+d` | Scroll preview up/down |
| `Ctrl+c` / `Esc` | Close picker |

Multi-select with `Tab` then `Enter` opens all selected files as buffers, or send to quickfix with `Ctrl+q`.

## Terminal (nvterm)

A horizontal split terminal with smart sizing.

| Key | Action |
|-----|--------|
| `Alt+h` | Toggle terminal at half height; if full → shrink to half |
| `Alt+j` | Toggle terminal at full height; if half → expand to full |
| `Alt+k` | Increase terminal height by 5 lines |
| `Alt+l` | Decrease terminal height by 5 lines |
| `` Alt+` `` | Simple toggle horizontal terminal |

All of these work from normal, insert, and terminal mode.

## Git

Two tools, split by job: **gitsigns** = see + stage hunks, **fugitive** = commit + push.

### Daily loop

| Key | Action |
|-----|--------|
| `]h` / `[h` | jump to next/prev hunk |
| `<leader>ph` | preview hunk diff |
| `:Gitsigns stage_hunk` | stage just the hunk under cursor |
| `<leader>gg` | **toggle** fugitive status (open ⇄ close, from anywhere) |
| `<leader>gt` | Telescope git_status: quick "what's dirty?" glance only (no commit/push) |

### Inside fugitive status

| Key | Action |
|-----|--------|
| `s` / `u` | stage / unstage file under cursor |
| `=` | inline diff of file |
| `cc` | commit (opens message buffer) |
| `ca` | amend last commit |
| `gq` | close status window |

Then `:Git push` / `:Git pull --rebase`, no terminal needed.

### Notes

- `<leader>gg` is a custom toggle: closes any open fugitive status window, else runs `:Git`. Defined in `plugins/init.lua`.
- `<A-g>` removed: terminal wasn't sending Alt (macOS Option key). Fix if wanted: iTerm2 → Keys → Left Option: **Esc+** (unblocks all other `Alt+` maps too).
- **Inline blame** always on via gitsigns (`current_line_blame`).

| Key | Action |
|-----|--------|
| `Alt+g` | Open Fugitive status window (works from any mode) |
| `:Git blame` / `:Gblame` | Line-by-line blame |
| `:Gdiffsplit` | Diff current file against HEAD |
| `:Gdelete` | Delete file via git |

In the Fugitive status window: `s` to stage, `u` to unstage, `cc` to commit, `=` to inline diff, `Enter` to open file, `dv` for vertical diff.

## LSP (Language Server Protocol)

Servers configured: `html`, `cssls`, `ts_ls` (TypeScript), `svelte`, `roslyn_ls` (C#/.NET), `pyright` (Python).

Default NvChad LSP mappings:

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `gi` | Go to implementation |
| `<leader>sh` | Signature help |
| `<leader>ra` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>D` | Type definition |
| `<leader>ds` | Document symbols |
| `[d` / `]d` | Jump to previous/next diagnostic |
| `<leader>e` | Show diagnostic float |

## Formatting (conform.nvim)

- **Lua**: formatted with `stylua` on demand
- Format command: `:ConformFormat` or NvChad default `<leader>fm`
- (CSS/HTML prettier is commented out, can be re-enabled in `lua/configs/conform.lua`)

## Treesitter

On the **`main` branch** (master is frozen and broken on nvim 0.12, never pin master).

- Parsers built by the **tree-sitter CLI** (`brew install tree-sitter`), required, or `:TSInstallAll` fails with ENOENT
- Installed: `vim`, `lua`, `vimdoc`, `html`, `css`, `markdown`, `markdown_inline`
- Markdown needs **both** markdown parsers: `markdown` = blocks, `markdown_inline` = bold/links
- Code blocks in markdown highlight via injections: only if that language's parser is installed
- Install/update: `:TSInstallAll` (reads `ensure_installed`), check: `:checkhealth nvim-treesitter`

## AI Assistants

### gp.nvim (in-editor AI chat/edit)

Agents configured: `qwen3-5` (Ollama), `llama` (Ollama), `haiku` (Anthropic Claude).

| Key | Action |
|-----|--------|
| `Ctrl+g, Ctrl+i` | Toggle AI chat popup |
| `Ctrl+g, Ctrl+a` | Append AI output after cursor |
| `Ctrl+g, Ctrl+r` | Rewrite selection with AI |
| `Ctrl+g, Ctrl+g` | Show current agent info |
| `Ctrl+g, Ctrl+n` | Switch to next agent |
| `Ctrl+g, Ctrl+c` | New chat with entire current file as context |

### model-cmp.nvim (AI inline completions)

Shows AI-powered virtual text completions inline as you type.

| Key | Action |
|-----|--------|
| `Ctrl+q` (insert) | Accept/capture the first completion suggestion |

The virtual text is shown in a reddish color. Enabled automatically on startup via `ModelCmp virtualtext enable`.

### opencode.nvim

| Key | Action |
|-----|--------|
| `Ctrl+a` (n/v) | Ask opencode with current file context |
| `Ctrl+x` (n/v) | Execute opencode action picker |
| `Ctrl+.` (n/t) | Toggle opencode panel |
| `Ctrl+o, Ctrl+o` | Toggle opencode (from any mode) |
| `go` (n/v) | Add range to opencode (operator) |
| `goo` | Add current line to opencode |
| `Shift+Ctrl+u` | Scroll opencode panel up |
| `Shift+Ctrl+d` | Scroll opencode panel down |
| `+` | Increment number under cursor (remapped from Ctrl+a) |
| `-` | Decrement number under cursor (remapped from Ctrl+x) |

### 99 (ThePrimeagen/99)

AI coding agent integration (currently using OpenCode provider).

| Key | Action |
|-----|--------|
| `<leader>9v` (visual) | Send visual selection to agent |
| `<leader>9x` | Stop all in-flight agent requests |
| `<leader>9s` | Search via agent |

Supports `AGENT.md` files: place one in your project root or subdirectory and it's auto-loaded as context.
Custom rules can be placed in `scratch/custom_rules/<name>/SKILL.md`.

## Markdown Preview

| Key / Command | Action |
|---|---|
| `Ctrl+m` | Open markdown preview in browser |
| `:MarkdownPreviewToggle` | Toggle preview |
| `:MarkdownPreviewStop` | Stop preview server |

Only activates for `.md` files.

## Keybinding Discovery (nvim-mapper)

`:Telescope mapper`: browse all mapped keybindings with descriptions in a searchable Telescope picker.

## Windows / Panes

Open splits and navigate between them (normal mode):

| Key | Action |
|-----|--------|
| `C-w v` or `:vsp` | Open vertical split |
| `C-w s` or `:sp` | Open horizontal split |
| `C-w h` | Focus window left |
| `C-w l` | Focus window right |
| `C-w j` | Focus window down |
| `C-w k` | Focus window up |

## Buffers

| Key | Action |
|-----|--------|
| `Tab` | Next buffer |
| `Shift+Tab` | Previous buffer |
| `<leader>x` | Close buffer |
| `<leader>b` | New buffer |
| `<leader>fb` | Find open buffers (Telescope) |

## General Mappings

| Key | Action |
|-----|--------|
| `;` | Enter command mode (same as `:`) |
| `jk` / `jj` (insert) | Exit insert mode |
| `Ctrl+s` / `Alt+s` | Save file (works in normal, insert, visual) |

## NvChad Built-ins (commonly underused)

NvChad ships many features you may not know about:

- **Tabufline**: buffer tabs at the top, `Tab` / `Shift+Tab` to cycle, `<leader>x` to close buffer
- **Statusline**: shows mode, git branch, LSP status, file info
- **Cheatsheet**: `:NvCheatsheet`, full list of all default mappings
- **Theme switcher**: `<leader>th`, live preview and switch themes
- **Terminal**: NvChad also has `<A-i>` (float), `<A-h>` (horizontal), `<A-v>` (vertical) via nvterm (some overlap with custom mappings above)
- **Comment toggle**: `gcc` (line), `gc` + motion, `gc` in visual, via Comment.nvim
- **Autopairs**: brackets/quotes auto-close
- **Indent guides**: visual indentation lines
- **Mason**: `:Mason`, install/manage LSP servers, formatters, linters via a UI
