# Neovim Keymaps

This document outlines all the keymaps configured in your Neovim setup, extracted from various configuration files.

---

## `lua/oussama/core/keymaps.lua`

- **`jj`**: Exit insert mode (Insert mode)
- **`j`**: Move down (Normal mode, Operator-pending mode, Visual mode) - handles wrapped lines
- **`k`**: Move up (Normal mode, Operator-pending mode, Visual mode) - handles wrapped lines
- **`<S-h>`**: Jump to beginning of line (Normal mode, Operator-pending mode, Visual mode)
- **`<S-l>`**: Jump to end of line (Normal mode, Operator-pending mode, Visual mode)
- **`<leader>nh`**: Clear search highlights (Normal mode)
- **`x`**: Delete without copying into register (Normal mode)
- **`c`**: Change without copying into register (Normal mode)
- **`<C-d>`**: Scroll half page down, keeping cursor centered (Normal mode)
- **`<C-u>`**: Scroll half page up, keeping cursor centered (Normal mode)
- **`<leader>y`**: Copy to system clipboard (Normal mode, Visual mode)
- **`<leader>p`**: Paste from system clipboard (Normal mode)
- **`<leader>p`**: Paste from system clipboard and replace selected text (Visual mode)
- **`<leader>sv`**: Split window vertically (Normal mode)
- **`<leader>sh`**: Split window horizontally (Normal mode)
- **`<leader>se`**: Make splits equal size (Normal mode)
- **`<leader>sx`**: Close current split (Normal mode)
- **`<leader><leader>y`**: Append selection to clipboard (Visual mode)
- **`<leader><leader>p`**: Clear clipboard (Normal mode, Visual mode)

---

## `lua/oussama/plugins/lsp/lspconfig.lua`

- **`<leader>ca`**: Code Action (Normal mode, Visual mode)
- **`<leader>rn`**: Rename Symbol (Normal mode)
- **`<leader>rs`**: Restart LSP (Normal mode)
- **`<leader>xx`**: Show line diagnostics (Normal mode)

---

## `lua/oussama/plugins/lsp/linting.lua`

- **`<leader>ll`**: Trigger linting for current file (Normal mode)
- **`<leader>lh`**: Toggle Inlay Hints (Normal mode)

---

## `lua/oussama/plugins/lsp/treesitter.lua`

- **`<C-space>`**: Init incremental selection (Normal mode)
- **`<C-space>`**: Node incremental selection (Normal mode)
- **`<bs>`**: Node decremental selection (Normal mode)

---

## `lua/oussama/plugins/yazi.nvim`

- **`<leader>-`**: Open yazi at the current file (Normal mode, Visual mode)
- **`<leader>cw`**: Open the file manager in nvim's working directory (Normal mode)
- **`<c-up>`**: Resume the last yazi session (Normal mode)
- **`<f1>`**: Show help (Yazi keymaps)

---

## `lua/oussama/plugins/undotree.lua`

- **`<leader>u`**: Toggle undotree (Normal mode)

---

## `lua/oussama/plugins/trouble.lua`

- **`<leader>xw`**: Open trouble workspace diagnostics (Normal mode)
- **`<leader>xd`**: Open trouble document diagnostics (Normal mode)

---

## `lua/oussama/plugins/snaks.nvim`

- **`<leader>:`**: Command History (Normal mode)
- **`<leader><space>`**: Smart Find Files (Normal mode)
- **`<leader>e`**: File Explorer (Normal mode)
- **`<leader>fb`**: Buffers (Normal mode)
- **`<leader>ff`**: Find Files (Normal mode)
- **`<leader>fg`**: Find Git Files (Normal mode)
- **`<leader>fp`**: Projects (Normal mode)
- **`<leader>fr`**: Recent (Normal mode)
- **`<leader>fz`**: Grep (Normal mode)
- **`<leader>fn`**: Notification History (Normal mode)
- **`<leader>fc`**: Colorschemes (Normal mode)
- **`gd`**: Goto Definition (Normal mode)
- **`gD`**: Goto Declaration (Normal mode)
- **`gr`**: References (Normal mode)
- **`gI`**: Goto Implementation (Normal mode)
- **`gy`**: Goto Type Definition (Normal mode)
- **`<leader>ss`**: LSP Symbols (Normal mode)
- **`<leader>sS`**: LSP Workspace Symbols (Normal mode)
- **`<leader>sq`**: Quickfix List (Normal mode)
- **`<leader>sd`**: Diagnostics (Normal mode)
- **`<leader>sD`**: Buffer Diagnostics (Normal mode)
- **`<leader>sH`**: Highlights (Normal mode)
- **`<leader>sk`**: Keymaps (Normal mode)
- **`<leader>bd`**: Delete Buffer (Normal mode)
- **`<leader>gg`**: Lazygit (Normal mode)
- **`<leader>nu`**: Dismiss All Notifications (Normal mode)

---

## `lua/oussama/plugins/git.lua`

- **`<leader>do`**: Open diffview (Normal mode)
- **`<leader>dx`**: Close diffview (Normal mode)
- **`<leader>df`**: Toggle files (Normal mode)
- **`<leader>dh`**: File history (Normal mode)
- **`]h`**: Next Hunk (Normal mode)
- **`[h`**: Prev Hunk (Normal mode)
- **`<leader>hs`**: Stage hunk (Normal mode)
- **`<leader>hr`**: Reset hunk (Normal mode)
- **`<leader>hs`**: Stage hunk (Visual mode)
- **`<leader>hr`**: Reset hunk (Visual mode)
- **`<leader>hS`**: Stage buffer (Normal mode)
- **`<leader>hR`**: Reset buffer (Normal mode)
- **`<leader>hu`**: Undo stage hunk (Normal mode)
- **`<leader>hp`**: Preview hunk (Normal mode)
- **`<leader>hb`**: Blame line (Normal mode)
- **`<leader>hB`**: Toggle line blame (Normal mode)
- **`<leader>hd`**: Diff this (Normal mode)
- **`<leader>hD`**: Diff this ~ (Normal mode)
- **`ih`**: Gitsigns select hunk (Operator-pending mode, Visual mode)

---

## `lua/oussama/plugins/flash.nvim`

- **`s`**: Flash (Normal mode, Visual mode, Operator-pending mode)
- **`S`**: Flash Treesitter (Normal mode, Visual mode, Operator-pending mode)
- **`r`**: Remote Flash (Operator-pending mode)
- **`R`**: Treesitter Search (Operator-pending mode, Visual mode)
- **`<c-s>`**: Toggle Flash Search (Command mode)

---

## `lua/oussama/plugins/lsp/formating.lua`

- **`<leader>mp`**: Format file or range (in visual mode) (Normal mode, Visual mode)
