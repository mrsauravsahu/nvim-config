# CLAUDE.md

Guidance for Claude Code when working in this repo.

## Testing nvim behavior

When testing/reproducing something in a running nvim instance (headless or interactive):

- Only open Neovim against **this directory** (`~/.config/nvim`), not other paths.
- Use `playground/` inside this repo for throwaway test files (creating files, editing, reproducing bugs, etc). It's gitignored, not part of the real config.
- Don't create test fixtures elsewhere in the repo (e.g. root, `lua/`) — they pollute the real config tree.
