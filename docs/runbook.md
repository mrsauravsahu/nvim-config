---
title: "nvim-config Runbook"
subtitle: "NvChad-based Neovim — feature guide & operations"
author: "Saurav Sahu (@mrsauravsahu)"
date: "2026-08-01"
---

# Overview

Personal runbook for **@mrsauravsahu/nvim-config** — goal: use everything that's installed.

Built on **NvChad v2.5** as a plugin: config lives in `lua/`, NvChad updates cleanly underneath.
Source: <https://github.com/NvChad/NvChad>

## Four Layers

| Layer | What it covers |
|---|---|
| **Core editing** | Treesitter, LSP, conform, folds, whitespace rendering |
| **Workspace** | nvim-tree (right), auto-session, nvterm, telescope + nvim-mapper |
| **Git** | fugitive + gitsigns |
| **AI** | model-cmp (inline), gp.nvim (chat/rewrite), opencode (agentic), 99 (prompt-driven) |

> Rule of thumb: **the AI layer has the most unused power.**

## IDE Capability Map

What a full IDE gives you, and where this config delivers it. Use this as the index.

| Capability | Status | Section |
|---|---|---|
| Syntax highlighting | ✅ Treesitter | Treesitter |
| Autocomplete | ✅ nvim-cmp (LSP + snippets + buffer + path) | Autocompletion |
| Snippets | ✅ LuaSnip + friendly-snippets | Snippets |
| Code navigation (defs/refs/symbols) | ✅ LSP | LSP |
| Rename / code actions | ✅ LSP | LSP |
| Diagnostics / problems | ✅ LSP + quickfix + Telescope | Diagnostics & Quickfix |
| Find in file / project | ✅ `/`, Telescope live-grep | Search & Replace |
| Project-wide replace | ✅ quickfix + `:cdo` | Search & Replace |
| Formatting | ✅ conform.nvim | Formatting |
| Code folding | ✅ indent folds | Folding |
| Multi-cursor / column edit | ✅ visual block | Column Editing |
| File explorer | ✅ nvim-tree | UI & Theme |
| Integrated terminal | ✅ nvterm | Terminal |
| Version control | ✅ fugitive + gitsigns | Git |
| Sessions / workspace restore | ✅ auto-session | Sessions |
| AI assist | ✅ 4 tools | AI Assistants |
| Step debugger (DAP) | ❌ not configured | Not Configured |
| Linting (standalone) | ❌ LSP diagnostics only | Not Configured |
| Test runner | ❌ run tests in terminal | Not Configured |

# UI & Theme

- **Theme**: `bearded-arc` — change in `lua/chadrc.lua` → `M.base46.theme`
- **NvDash**: startup dashboard loads automatically
- **Whitespace rendering**: spaces as `·`, tabs as `»`, trailing spaces highlighted, overflow markers `⟩⟨`
- **Italic comments** via highlight override
- **NvimTree** file explorer opens on the **right side**, shows dotfiles and git-ignored files
  - Auto-opens on startup when no saved session exists
  - Toggle: `Ctrl+\`, `Alt+\`, or `Alt+b` (works in normal, insert, terminal mode)

# Sessions (auto-session)

Sessions are saved **per working directory** automatically.

- Opening nvim in a project directory restores the last session (open files, splits, etc.)
- Terminal windows are closed before saving (cannot be restored cleanly)
- NvimTree is closed before restore and reopened after

# File Finding (Telescope)

| Key | Action |
|-----|--------|
| `Alt+p` | Toggle find files (respects `.gitignore`, shows dotfiles); closes picker if open |
| `Alt+o` | Toggle find files ignoring `.gitignore` (shows everything); closes picker if open |

Both show dotfiles (`.gitignore`, `.env`, etc.) but hide `.git/` internals. Both work from normal, insert, and terminal mode.

NvChad default Telescope mappings:

| Key | Action |
|-----|--------|
| `<leader>fw` | Live grep across project |
| `<leader>fb` | Find open buffers |
| `<leader>fh` | Find help tags |
| `<leader>fo` | Find old/recent files |
| `<leader>gc` | Git commits |
| `<leader>gt` | Git status |

## Inside a Picker

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

Multi-select with `Tab` then `Enter` opens all selected files as buffers. Send to quickfix with `Ctrl+q`.

# Terminal (nvterm)

Horizontal split terminal with smart sizing.

| Key | Action |
|-----|--------|
| `Alt+h` | Toggle terminal at half height; if full → shrink to half |
| `Alt+j` | Toggle terminal at full height; if half → expand to full |
| `Alt+k` | Increase terminal height by 5 lines |
| `Alt+l` | Decrease terminal height by 5 lines |
| `` Alt+` `` | Simple toggle horizontal terminal |

All work from normal, insert, and terminal mode.

# Git

Two tools, split by job: **gitsigns** = see + stage hunks; **fugitive** = commit + push.

## Daily Loop

| Key | Action |
|-----|--------|
| `]h` / `[h` | Jump to next/prev hunk |
| `<leader>ph` | Preview hunk diff |
| `:Gitsigns stage_hunk` | Stage the hunk under cursor |
| `<leader>gg` | Toggle fugitive status (open ↔ close, from anywhere) |
| `<leader>gt` | Telescope git_status: quick "what's dirty?" glance |

## Inside Fugitive Status

| Key | Action |
|-----|--------|
| `s` / `u` | Stage / unstage file under cursor |
| `=` | Inline diff of file |
| `cc` | Commit (opens message buffer) |
| `ca` | Amend last commit |
| `gq` | Close status window |

Then `:Git push` / `:Git pull --rebase` — no terminal needed.

## Extra Git Commands

| Key / Command | Action |
|---|---|
| `Alt+g` | Open Fugitive status window (any mode) |
| `:Git blame` / `:Gblame` | Line-by-line blame |
| `:Gdiffsplit` | Diff current file against HEAD |
| `:Gdelete` | Delete file via git |

**Inline blame** is always on via gitsigns (`current_line_blame = true`).

# Autocompletion (nvim-cmp)

The completion popup that fires as you type. Sources, in order: **LSP** → **snippets** → **open buffers** → **Neovim Lua API** → **filesystem paths**.

This is separate from AI completion — `model-cmp` is the reddish inline ghost text (see AI Assistants); nvim-cmp is the classic popup menu.

## Inside the Popup

| Key | Action |
|-----|--------|
| `Ctrl+n` / `Tab` | Next item |
| `Ctrl+p` / `Shift+Tab` | Previous item |
| `Enter` | Confirm selection |
| `Ctrl+Space` | Force-open menu |
| `Ctrl+e` | Close menu |
| `Ctrl+f` / `Ctrl+d` | Scroll doc window down / up |

`Tab` also expands/jumps snippets when the cursor sits on a snippet trigger, so it does double duty. Nothing typed but menu closed → `Ctrl+Space` reopens it.

# Snippets (LuaSnip)

`friendly-snippets` ships VS Code-style snippets for most languages, loaded automatically.

| Key | Action |
|-----|--------|
| `Tab` | Expand snippet under cursor, or jump to next placeholder |
| `Shift+Tab` | Jump to previous placeholder |

Type a trigger (e.g. `fn`, `for`), see it in the cmp menu, press `Tab` to expand, then `Tab`/`Shift+Tab` between fields.

# LSP

Servers configured: `html`, `cssls`, `ts_ls` (TypeScript), `svelte`, `roslyn_ls` (C#/.NET), `pyright` (Python).

> **Note:** `roslyn_ls` requires the `CLI_CONFIG_ROOT` environment variable to be set — it points to the Roslyn language server DLL path.

## Default NvChad LSP Mappings

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

# Diagnostics & Quickfix

The "Problems panel" equivalent. Diagnostics come from the LSP servers above.

| Key / Command | Action |
|---|---|
| `<leader>e` | Float showing the diagnostic under cursor |
| `[d` / `]d` | Prev / next diagnostic in file |
| `:Telescope diagnostics` | Searchable list of all diagnostics in the workspace |
| `:copen` / `:cclose` | Open / close the quickfix list |
| `]q` / `[q` | Next / prev quickfix entry |

The **quickfix list** is the shared results panel: grep hits, multi-select from Telescope (`Ctrl+q`), and `:make` output all land there. Navigate with `:cnext` / `:cprev`.

# Search & Replace

## In the Current File

| Key / Command | Action |
|---|---|
| `/text` / `?text` | Search forward / backward |
| `n` / `N` | Next / previous match |
| `*` / `#` | Search word under cursor forward / backward |
| `:%s/old/new/g` | Replace all in file |
| `:%s/old/new/gc` | Replace all, confirm each |
| `:s/old/new/g` | Replace all on current line |

Search matches highlight as you type (incremental). `:noh` clears the highlight.

## Across the Project

1. `<leader>fw` — Telescope live-grep the whole project.
2. In the picker, `Ctrl+q` sends all results to the **quickfix list**.
3. `:cdo s/old/new/g | update` — run the replace on every quickfix entry and save.

For a single word, `<leader>fw` then type it; jump straight to any hit with `Enter`.

# Folding

Folding is **indent-based**, and all folds start **open** (`foldlevelstart=99`) so nothing is hidden until you ask.

| Key | Action |
|-----|--------|
| `za` | Toggle fold under cursor |
| `zc` / `zo` | Close / open fold under cursor |
| `zR` / `zM` | Open all / close all folds |
| `zj` / `zk` | Jump to next / previous fold |

# Column Editing

Multi-line edits without a true multi-cursor plugin — use visual block.

1. `Ctrl+v` — enter visual block, select a column with `j`/`k`.
2. `I` (insert before) or `A` (append after), type your text.
3. `Esc` — the edit applies to every selected line.

`c` to change the block, `d` to delete it, `r` to replace each char.

# Formatting (conform.nvim)

- **Lua**: formatted with `stylua` on demand
- Format: `:ConformFormat` or `<leader>fm`
- CSS/HTML prettier is commented out in `lua/configs/conform.lua` — can be re-enabled

# Treesitter

Running on the **`main` branch** (the `master` branch is frozen and broken on nvim 0.12).

- Parsers built by the **tree-sitter CLI** (`brew install tree-sitter`) — required, or `:TSInstallAll` fails
- Installed: `vim`, `lua`, `vimdoc`, `html`, `css`, `markdown`, `markdown_inline`
- Markdown needs **both** parsers: `markdown` = block structure, `markdown_inline` = bold/links/etc.
- Code blocks in markdown highlight via injections — only if that language's parser is installed
- Install/update: `:TSInstallAll` — check: `:checkhealth nvim-treesitter`

# AI Assistants

## gp.nvim — In-editor Chat & Edit

Agents: `qwen3-5` (Ollama), `llama` (Ollama), `haiku` (Anthropic Claude Haiku).

All chords are `Alt+g` **then** a second `Alt` key (not `Ctrl`).

| Key | Action |
|-----|--------|
| `Alt+g, Alt+i` | Toggle AI chat popup |
| `Alt+g, Alt+a` | Append AI output after cursor |
| `Alt+g, Alt+r` | Rewrite selection with AI |
| `Alt+g, Alt+g` | Show current agent info |
| `Alt+g, Alt+n` | Switch to next agent |
| `Alt+g, Alt+c` | New chat with entire current file as context |

> **Note:** `<A-g>` alone is also mapped to open Fugitive (see Git), which fires immediately and can shadow these chords. Use `:Gp*` commands directly (`:GpChatToggle`, `:GpRewrite`, …) if a chord doesn't land.

## model-cmp.nvim — Inline Completions

Shows AI-powered virtual text completions inline as you type.

| Key | Action |
|-----|--------|
| `Alt+q` (insert) | Accept the first completion suggestion |

Virtual text displays in a reddish colour. Enabled automatically on startup. This runs against a local model endpoint (`127.0.0.1:9000`) — no suggestions means that server isn't up.

## opencode.nvim — Agentic Coding

| Key | Action |
|-----|--------|
| `Ctrl+a` (n/v) | Ask opencode with current file context |
| `Ctrl+x` (n/v) | Execute opencode action picker |
| `Ctrl+.` (n/t) | Toggle opencode panel |
| `Alt+o, Alt+o` (n/v/i/t) | Toggle opencode panel (chord alternative) |
| `go` (n/v) | Add range to opencode (operator) |
| `goo` | Add current line to opencode |
| `Shift+Ctrl+u` | Scroll opencode panel up |
| `Shift+Ctrl+d` | Scroll opencode panel down |
| `+` | Increment number under cursor (remapped from Ctrl+a) |
| `-` | Decrement number under cursor (remapped from Ctrl+x) |

## 99 (ThePrimeagen/99) — Prompt-driven Agent

AI coding agent using the OpenCode provider.

| Key | Action |
|-----|--------|
| `<leader>9v` (visual) | Send visual selection to agent |
| `<leader>9x` | Stop all in-flight agent requests |
| `<leader>9s` | Search via agent |

Supports `AGENT.md` files: place one in your project root or a subdirectory — it is auto-loaded as context. Custom rules go in `scratch/custom_rules/<name>/SKILL.md`.

# Markdown Preview

| Key / Command | Action |
|---|---|
| `Alt+m` | Open markdown preview in browser |
| `:MarkdownPreviewToggle` | Toggle preview |
| `:MarkdownPreviewStop` | Stop preview server |

Only activates for `.md` files.

# Keybinding Discovery

`:Telescope mapper` — browse all mapped keybindings with descriptions in a searchable picker.

# Windows & Splits

These are stock Vim window commands — nothing in this config remaps `C-w`.

## Open a split

| Key | Action |
|-----|--------|
| `C-w v` or `:vsp` | Open vertical split (current buffer) |
| `C-w s` or `:sp` | Open horizontal split (current buffer) |
| `:vs <file>` | Vertical split, opening `<file>` in it |
| `:sp <file>` | Horizontal split, opening `<file>` in it |

To open a *different* file straight into a new split, use the picker rather than
splitting first:

| Where | Key | Action |
|-------|-----|--------|
| Telescope | `Ctrl+v` | Open selection in vertical split |
| Telescope | `Ctrl+x` | Open selection in horizontal split |
| Telescope | `Ctrl+t` | Open selection in new tab |
| NvimTree (`Alt+b`) | `Ctrl+v` | Open file under cursor in vertical split |
| NvimTree (`Alt+b`) | `Ctrl+x` | Open file under cursor in horizontal split |
| NvimTree (`Alt+b`) | `Ctrl+t` | Open file under cursor in new tab |

## Focus

| Key | Action |
|-----|--------|
| `C-w h` | Focus window left |
| `C-w l` | Focus window right |
| `C-w j` | Focus window down |
| `C-w k` | Focus window up (bottom pane → top) |
| `C-w w` | Cycle to next window (wraps) |
| `C-w W` | Cycle to previous window |
| `C-w p` | Focus the previously focused window (toggle back and forth) |
| `C-w t` / `C-w b` | Focus top-left / bottom-right window |

## Close

| Key | Action |
|-----|--------|
| `C-w q` or `:q` | Close current window |
| `C-w o` | Close all *other* windows |

Note: `<leader>x` closes the **buffer**, not the window. See [Buffers](#buffers).

## Resize

| Key | Action |
|-----|--------|
| `C-w =` | Equalize all window sizes |
| `C-w _` | Maximise height |
| `C-w \|` | Maximise width |
| `C-w -` / `C-w +` | Shrink / grow height |
| `C-w <` / `C-w >` | Narrow / widen |
| `:vertical resize 80` | Set exact width |

## Rearrange

| Key | Action |
|-----|--------|
| `C-w H` / `C-w J` / `C-w K` / `C-w L` | Move current window to far left / bottom / top / right |
| `C-w r` | Rotate windows |
| `C-w x` | Swap current window with the next |
| `C-w T` | Break current window out into its own tab |

`C-w H` / `C-w K` is how you flip a horizontal split to vertical and back.

Session layout (open files and splits) is restored per project directory by
auto-session — see [Sessions](#sessions-auto-session).

# Navigating back & forth

Vim tracks three separate histories. They are easy to confuse, so:

| Key | Action | History |
|-----|--------|---------|
| `C--` (Ctrl+minus) | Jump back to previous cursor position | jumplist |
| `C-=` (Ctrl+equal) | Jump forward to next cursor position | jumplist |
| `:jumps` | Show the jumplist | jumplist |
| `C-^` or `C-6` | Toggle to the alternate (last) buffer | alternate file |
| `g;` | Go to previous change position | changelist |
| `g,` | Go to next change position | changelist |
| `` `. `` | Jump to the position of the last change | changelist |
| `:changes` | Show the changelist | changelist |

The **jumplist** records "far" cursor moves both across files *and* within one
file: `gg`, `G`, `/search`, `}`, `:42`, LSP go-to-definition, and opening a file
from Telescope all push an entry. So jumping back after a `/search` returns you
to the pre-search line in the same file — it is not a "go back one file"
command. For that, use `C-^`.

## Why not `C-o` / `C-i`?

- **`C-o` is mapped to `<Nop>` in this config** (`lua/mappings.lua`). Use `C--`.
- **`C-i` is unreliable here.** In a terminal, `Ctrl+i` and `Tab` are the same
  byte (`0x09`), and NvChad maps `Tab` to "next buffer" — so `C-i` gets
  swallowed and switches buffers instead of jumping forward. `C-=` avoids the
  collision entirely.

## Terminal support

`Ctrl+-` is bound twice: as `<C-_>` (the byte most terminals send for it) and as
`<C-->` (the kitty keyboard protocol form), so it works either way.

`Ctrl+=` has **no legacy control code**. It only reaches Neovim from a terminal
with the kitty keyboard protocol enabled (kitty, WezTerm, Ghostty, foot, and
Alacritty ≥ 0.13). In a terminal without it, `C-=` will do nothing — rebind the
forward jump to a plain key such as `<leader>i` in `lua/mappings.lua`.

# Buffers

| Key | Action |
|-----|--------|
| `Tab` | Next buffer |
| `Shift+Tab` | Previous buffer |
| `<leader>x` | Close buffer |
| `<leader>b` | New buffer |
| `<leader>fb` | Find open buffers (Telescope) |

# General Mappings

| Key | Action |
|-----|--------|
| `;` | Enter command mode (same as `:`) |
| `jj` (insert) | Exit insert mode |
| `kk` (insert) | Save file (`:w`) without leaving insert |
| `Ctrl+s` / `Alt+s` | Save file (normal, insert, visual) |

# NvChad Built-ins

Features that ship with NvChad you may not be using:

| Feature | How to access |
|---|---|
| **Tabufline** | Buffer tabs at top; `Tab` / `Shift+Tab` to cycle, `<leader>x` to close |
| **Statusline** | Shows mode, git branch, LSP status, file info |
| **Cheatsheet** | `:NvCheatsheet` — full list of all default mappings |
| **Theme switcher** | `<leader>th` — live preview and switch themes |
| **Comment toggle** | `gcc` (line), `gc` + motion, `gc` in visual |
| **Autopairs** | Brackets/quotes auto-close |
| **Indent guides** | Visual indentation lines |
| **Mason** | `:Mason` — install/manage LSP servers, formatters, linters |

# Not Configured (Gaps)

Standard IDE features this config does **not** ship yet. Reach for these when needed.

| Missing | Today's workaround | To add |
|---|---|---|
| **Step debugger** | Run under an external debugger, or print-debug | `nvim-dap` + `nvim-dap-ui` + language adapters |
| **ESLint / Ruff diagnostics** | `ts_ls`/`pyright` give type errors only, not lint rules | Add `eslint-lsp` / `ruff` **as LSP servers** via `:Mason` — not a plugin |
| **Test runner** | Run tests in the terminal (`Alt+h`) | *Deferred — not planned for now* |
| **Prettier formatting** | Lua via `stylua` only | Uncomment `css`/`html` prettier in `lua/configs/conform.lua` |
| **Format on save** | Manual `<leader>fm` | Uncomment `format_on_save` block in `lua/configs/conform.lua` |

Install LSP servers, formatters, and linters through `:Mason`.

# How This Compares to Popular Distros

This config is **NvChad + a hand-built AI layer**. That base stays — the point of this section is only to show what the batteries-included distros wire up by default, so you can cherry-pick.

## Feature Matrix

| Feature | This config | NvChad (vanilla) | LazyVim | AstroNvim | kickstart |
|---|---|---|---|---|---|
| Philosophy | Minimal base + custom | Minimal, fast, pretty | Full IDE out of box | Full IDE, community packs | Single-file teaching starter |
| Plugin manager | lazy.nvim | lazy.nvim | lazy.nvim | lazy.nvim | lazy.nvim |
| Completion | nvim-cmp **+ AI inline** | nvim-cmp | blink.cmp (cmp optional) | nvim-cmp / blink | nvim-cmp |
| LSP + Mason | ✅ | ✅ | ✅ | ✅ | ✅ |
| Step debugger (DAP) | ❌ | ❌ | ✅ (opt-in extra) | ✅ | ➕ (commented, opt-in) |
| Linting | via LSP (add in Mason) | via LSP | ✅ nvim-lint | ✅ none-ls | via LSP |
| Test runner | ❌ | ❌ | ✅ neotest (extra) | ✅ | ❌ |
| Diagnostics list UI | quickfix + Telescope | quickfix | ✅ trouble.nvim | ✅ | quickfix |
| Motions/jumps | native | native | ✅ flash.nvim | ✅ | native |
| Git | fugitive + gitsigns | gitsigns | gitsigns | gitsigns | gitsigns |
| Sessions | ✅ auto-session | ❌ | ✅ persistence | ✅ resession | ❌ |
| AI assistants | ✅ **4 tools** | ❌ | ❌ (add yourself) | ❌ (community) | ❌ |
| Language presets | manual | manual | ✅ extras system | ✅ astrocommunity | manual |

> Where you're **ahead**: the 4-tool AI layer (gp.nvim, opencode, model-cmp, 99) is richer than anything these distros ship — none bundle AI by default. That's the differentiator; keep it.
>
> Where you're **behind**: really just **debugging (DAP)**. Linting is covered through the LSP (add `eslint-lsp`/`ruff` in Mason — see Not Configured); a test runner is deliberately skipped.

## What to Borrow (keeps the NvChad base intact)

All of these are single plugins you can drop into `lua/plugins/init.lua` — no distro switch, no base change.

| Borrow from | Plugin | Fills gap |
|---|---|---|
| LazyVim / AstroNvim | `mfussenegger/nvim-dap` + `rcarriga/nvim-dap-ui` | Step debugging |
| LazyVim / AstroNvim | `folke/trouble.nvim` | A real diagnostics/quickfix panel |
| LazyVim | `folke/flash.nvim` | Fast jump-to-anywhere motions |
| Everyone | `folke/todo-comments.nvim` | Highlight + search `TODO`/`FIXME` |

**Not linting via a plugin.** Modern linters ship as language servers — add `eslint-lsp`, `ruff`, `stylelint-lsp` through `:Mason` and they flow into your existing LSP diagnostics. Roslyn already includes C# analyzers. Reserve `nvim-lint`/`none-ls` for the rare linter with no LSP (hadolint, markdownlint, shellcheck).

**Test runner** — intentionally skipped; run tests in the terminal.

## What NOT to Change

The "basics" already match what the big distros do — no reason to touch them:

- **NvChad base** (base46 theming, statusline, tabufline) — keep.
- **nvim-cmp** — LazyVim moved to blink.cmp, but cmp is still first-class everywhere and yours works; not worth churning.
- **Telescope, Mason, conform, gitsigns, treesitter** — identical choices to every distro above.

## Distro Notes

- **LazyVim** — closest target to aspire to feature-wise; its "extras" are opt-in language/tool packs you can read for wiring ideas.
- **AstroNvim v4** — `astrocommunity` is a large repo of ready-made plugin packs worth mining.
- **kickstart.nvim** — single well-commented file; the best reference when you want to understand *how* a feature is wired before copying it.
- **LunarVim** — effectively unmaintained (lead moved to AstroNvim); don't build on it.

*Researched Aug 2026. Sources: [daily.dev distro roundup](https://daily.dev/posts/4c5fbmmde), [LazyVim DeepWiki](https://deepwiki.com/LazyVim/LazyVim), [LazyVim DAP extra](http://www.lazyvim.org/extras/dap/core), [AstroNvim v4 docs](https://docs.astronvim.com/v4/configuration/v4_migration/), [LunarVim status](https://github.com/LunarVim/LunarVim/discussions/4518).*

