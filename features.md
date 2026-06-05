# Neovim Config Features

Built on **NvChad v3** with custom plugins and mappings.

---

## UI & Theme

- **Theme**: `aquarium` (change in `lua/chadrc.lua` → `M.base46.theme`)
- **NvDash**: startup dashboard loads automatically
- **Whitespace rendering**: spaces shown as `·`, tabs as `»`, trailing spaces highlighted, line overflow indicators `⟩⟨`
- **Italic comments** via highlight override
- **NvimTree** file explorer on the **right side**, shows dotfiles and git-ignored files
  - Auto-opens on startup if no saved session exists
  - Toggle: `Ctrl+\` or `Alt+\` (works in normal, insert, terminal mode)

---

## Sessions (auto-session)

Sessions are saved **per working directory** automatically.

- When you open nvim in a project directory, the last session is restored (open files, splits, etc.)
- Terminal windows are closed before saving (they can't be restored cleanly)
- NvimTree is closed before restore and reopened after

---

## File Finding (Telescope)

| Key | Action |
|-----|--------|
| `Ctrl+p` / `Alt+p` | Find files (respects .gitignore) |
| `Ctrl+o` / `Alt+o` | Find files ignoring .gitignore (shows everything) |

NvChad also ships these Telescope mappings by default:
- `<leader>fw` — live grep across project
- `<leader>fb` — find open buffers
- `<leader>fh` — find help tags
- `<leader>fo` — find old/recent files
- `<leader>gc` — git commits
- `<leader>gt` — git status

---

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

---

## Git

### gitsigns
- **Inline blame** shown on the current line automatically
- Signs in the gutter for added/changed/deleted lines
- NvChad default mappings: `]h` / `[h` to jump between hunks, `<leader>ph` to preview hunk

### vim-fugitive
| Key / Command | Action |
|---|---|
| `Alt+g` | Open Fugitive status window (works from any mode) |
| `:Git blame` / `:Gblame` | Line-by-line blame |
| `:Gdiffsplit` | Diff current file against HEAD |
| `:Gdelete` | Delete file via git |

In the Fugitive status window: `s` to stage, `u` to unstage, `cc` to commit, `=` to inline diff, `Enter` to open file, `dv` for vertical diff.

---

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

---

## Formatting (conform.nvim)

- **Lua**: formatted with `stylua` on demand
- Format command: `:ConformFormat` or NvChad default `<leader>fm`
- (CSS/HTML prettier is commented out — can be re-enabled in `lua/configs/conform.lua`)

---

## Treesitter

Syntax highlighting and code understanding for: `vim`, `lua`, `vimdoc`, `html`, `css`.
Additional languages are auto-installed by NvChad defaults (check `:TSInstallInfo`).

---

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

Supports `AGENT.md` files — place one in your project root or subdirectory and it's auto-loaded as context.
Custom rules can be placed in `scratch/custom_rules/<name>/SKILL.md`.

---

## Markdown Preview

| Key / Command | Action |
|---|---|
| `Ctrl+m` | Open markdown preview in browser |
| `:MarkdownPreviewToggle` | Toggle preview |
| `:MarkdownPreviewStop` | Stop preview server |

Only activates for `.md` files.

---

## Keybinding Discovery (nvim-mapper)

`:Telescope mapper` — browse all mapped keybindings with descriptions in a searchable Telescope picker.

---

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

---

## NvChad Built-ins (commonly underused)

NvChad ships many features you may not know about:

- **Tabufline**: buffer tabs at the top — `Tab` / `Shift+Tab` to cycle, `<leader>x` to close buffer
- **Statusline**: shows mode, git branch, LSP status, file info
- **Cheatsheet**: `:NvCheatsheet` — full list of all default mappings
- **Theme switcher**: `<leader>th` — live preview and switch themes
- **Terminal**: NvChad also has `<A-i>` (float), `<A-h>` (horizontal), `<A-v>` (vertical) via nvterm (some overlap with custom mappings above)
- **Comment toggle**: `gcc` (line), `gc` + motion, `gc` in visual — via Comment.nvim
- **Autopairs**: brackets/quotes auto-close
- **Indent guides**: visual indentation lines
- **Mason**: `:Mason` — install/manage LSP servers, formatters, linters via a UI
