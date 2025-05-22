vim.g.mapleader = " "

local keymap = vim.keymap

-- use jk to exit insert mode
keymap.set("i", "jj", "<ESC>", { desc = "Exit insert mode with jk" })
-- keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
-- keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit file" })
-- keymap.set("n", "<leader>Q", ":q!<CR>", { desc = "Force quit file" })
-- Move across wrapped lines
keymap.set("n", "j", "v:count > 0 ? 'j' : 'gj'", { noremap = true, expr = true, silent = true })
keymap.set("n", "k", "v:count > 0 ? 'k' : 'gk'", { noremap = true, expr = true, silent = true })

keymap.set({ "n", "o", "x" }, "<s-h>", "^", { desc = "Jump to beginning of line" })
keymap.set({ "n", "o", "x" }, "<s-l>", "g_", { desc = "Jump to end of line" })
-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- delete without copying into register
keymap.set("n", "x", '"_x', { noremap = true, silent = true })
keymap.set("n", "c", '"_c', { noremap = true, silent = true })
-- keymap.set("n", "d", '"_d', { noremap = true, silent = true })
-- keymap.set("n", "dd", '"_dd', { noremap = true, silent = true })

keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- System clipboard integration
keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to system clipboard" })
keymap.set("n", "<leader>p", '"+p', { desc = "Paste from system clipboard" })
keymap.set("v", "<leader>p", '"+p', { desc = "Paste from system clipboard and replace selected text" })

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- Simple clipboard functions for Wayland
vim.keymap.set("x", "<leader><leader>y", function()
	-- Yank the selection to the unnamed register
	vim.cmd("normal! y")

	-- Get the yanked text
	local yanked_text = vim.fn.getreg('"')

	-- Get current clipboard content
	local current_clipboard = vim.fn.system('wl-paste 2>/dev/null || echo ""')

	-- Append with newline
	local new_content = current_clipboard
	if new_content ~= "" then
		new_content = new_content .. "\n"
	end
	new_content = new_content .. yanked_text

	-- Update clipboard
	vim.fn.system("wl-copy", new_content)

	vim.notify("Text appended to clipboard")
end, { noremap = true, desc = "Append selection to clipboard" })

-- Clear clipboard function
vim.keymap.set({ "n", "x" }, "<leader><leader>p", function()
	vim.fn.system("wl-copy", "")
	vim.notify("Clipboard cleared")
end, { noremap = true, desc = "Clear clipboard" })
