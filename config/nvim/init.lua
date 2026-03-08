-- ~/.config/nvim/init.lua

-- =====================
-- Basic Options
-- =====================
local opt = vim.opt

opt.encoding     = "utf-8"
opt.fileencoding = "utf-8"
opt.number       = true
opt.relativenumber = true
opt.mouse        = ""
opt.clipboard    = "unnamedplus"

-- インデント
opt.autoindent  = true
opt.smartindent = true
opt.tabstop     = 4
opt.shiftwidth  = 4
opt.softtabstop = 4
opt.expandtab   = true

-- 表示
opt.termguicolors = true
opt.signcolumn    = "yes"
opt.cursorline    = true
opt.wrap          = false
opt.scrolloff     = 8
opt.sidescrolloff = 8
opt.splitright    = true
opt.splitbelow    = true

-- 検索
opt.ignorecase = true
opt.smartcase  = true
opt.hlsearch   = true
opt.incsearch  = true

-- パフォーマンス
opt.updatetime  = 250
opt.timeoutlen  = 300
opt.ttimeoutlen = 100  -- ESC+key シーケンス（Meta キー）の認識タイムアウト

-- その他
opt.undofile = true
opt.swapfile = false
opt.autoread = true

-- =====================
-- アクティブウィンドウ強調
-- =====================
local function setup_win_focus_hl()
  vim.api.nvim_set_hl(0, "ActiveWinSep",   { fg = "#e0af68", bold = true })
  vim.api.nvim_set_hl(0, "InactiveWinSep", { fg = "#1e1f2b" })
  vim.api.nvim_set_hl(0, "NormalNC",       { bg = "#13141f" })
end

setup_win_focus_hl()

vim.api.nvim_create_autocmd("ColorScheme", { callback = setup_win_focus_hl })

vim.api.nvim_create_autocmd("WinEnter", {
  callback = function() vim.opt_local.winhighlight = "WinSeparator:ActiveWinSep" end,
})
vim.api.nvim_create_autocmd("WinLeave", {
  callback = function() vim.opt_local.winhighlight = "WinSeparator:InactiveWinSep" end,
})

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- =====================
-- Keymaps
-- =====================
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

-- 保存・終了
map("n", "<Leader>w", ":w<CR>",   { desc = "Save file" })
map("n", "<Leader>q", ":q<CR>",   { desc = "Quit" })
map("n", "<Leader>Q", ":qa!<CR>", { desc = "Force quit all" })

-- ウィンドウリサイズ
map("n", "<C-Up>",    ":resize +2<CR>",          { desc = "Increase height" })
map("n", "<C-Down>",  ":resize -2<CR>",          { desc = "Decrease height" })
map("n", "<C-Left>",  ":vertical resize -2<CR>", { desc = "Decrease width" })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase width" })

-- ターミナルモードから抜ける
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- バッファ操作
map("n", "<S-l>", ":bnext<CR>",        { desc = "Next buffer" })
map("n", "<S-h>", ":bprevious<CR>",    { desc = "Prev buffer" })
map("n", "<C-w>c", ":bd<CR>",          { desc = "Close buffer" })
map("n", "<Leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- ハイライトクリア
map("n", "<Esc>", ":noh<CR><Esc>", { desc = "Clear highlights" })

-- ビジュアルモードでインデントしても選択維持
map("v", "<", "<gv")
map("v", ">", ">gv")

-- 行移動（Alt+j/k）
map("n", "<A-j>", ":m .+1<CR>==",      { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==",      { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ウィンドウ分割
map("n", "<Leader>sv", ":vsplit<CR>", { desc = "Vertical split" })
map("n", "<Leader>sh", ":split<CR>",  { desc = "Horizontal split" })

-- =====================
-- VSCode-like Keymaps (Ghostty の keybind と連動)
-- =====================

-- Cmd+S → Ctrl+S → 保存
map("n", "<C-s>", ":w<CR>",       { silent = true, desc = "Save (Cmd+S)" })
map("i", "<C-s>", "<Esc>:w<CR>a", { silent = true, desc = "Save (Cmd+S)" })
map("v", "<C-s>", "<Esc>:w<CR>",  { silent = true, desc = "Save (Cmd+S)" })

-- Cmd+Z → Ctrl+Z → アンドゥ
map("n", "<C-z>", "u", { desc = "Undo (Cmd+Z)" })

-- Cmd+P → Meta+P → ファイル検索
map("n", "<M-p>", function() require("telescope.builtin").find_files() end, { desc = "Quick open (Cmd+P)" })
map("t", "<M-p>", function() vim.cmd("stopinsert") require("telescope.builtin").find_files() end, { desc = "Quick open from terminal (Cmd+P)" })

-- Cmd+F → Meta+F → バッファ内検索
map("n", "<M-f>", "/", { desc = "Find in file (Cmd+F)" })

-- Cmd+Shift+F → Meta+G → グローバル検索
map("n", "<M-g>", function() require("telescope.builtin").live_grep() end, { desc = "Global search (Cmd+Shift+F)" })
map("i", "<M-g>", function() vim.cmd("stopinsert") require("telescope.builtin").live_grep() end, { desc = "Global search from insert" })
map("t", "<M-g>", function() vim.cmd("stopinsert") require("telescope.builtin").live_grep() end, { desc = "Global search from terminal" })

-- Cmd+Shift+P → Meta+C → コマンドパレット
map("n", "<M-c>", function() require("telescope.builtin").find_files() end, { desc = "Quick open (Cmd+Shift+P)" })
map("t", "<M-c>", function() vim.cmd("stopinsert") require("telescope.builtin").find_files() end, { desc = "Quick open from terminal" })

-- Cmd+B → ファイルエクスプローラー
map("n", "<M-e>", "<CMD>NvimTreeToggle<CR>", { desc = "File explorer (Cmd+B)" })

-- Cmd+W → Meta+W → バッファを閉じる
map("n", "<M-w>", ":bdelete<CR>", { silent = true, desc = "Close buffer (Cmd+W)" })

-- Cmd+Shift+K → Meta+K (大文字) → 行削除
map({ "n", "v" }, "<M-K>", "dd", { desc = "Delete line (Cmd+Shift+K)" })

-- Cmd+A → Meta+A → 全選択
map("n", "<M-a>", "ggVG", { desc = "Select all (Cmd+A)" })

-- Cmd+\ → Meta+\ → 縦分割
map("n", "<M-\\>", ":vsplit<CR>", { desc = "Split vertical (Cmd+\\)" })

-- =====================
-- lazy.nvim Bootstrap
-- =====================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
  change_detection = { notify = false },
  install = { colorscheme = { "tokyonight", "habamax" } },
  ui = { border = "rounded" },
})
