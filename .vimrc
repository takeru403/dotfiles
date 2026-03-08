" .vimrc

" ===============================
" 基本設定
" ===============================
set encoding=utf-8
set fileencoding=utf-8
set mouse=
set number
set relativenumber
set clipboard=unnamedplus
syntax on

set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab

set wrap
set linebreak

" ===============================
" プラグイン管理（vim-plug）
" ===============================
call plug#begin('~/.vim/plugged')

Plug 'preservim/nerdtree'
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-airline/vim-airline'

call plug#end()

" ===============================
" 外部ファイル変更の自動検知
" ===============================
set autoread
autocmd FocusGained,BufEnter * checktime

" ===============================
" キーマッピング
" ===============================
let mapleader = " "

" 保存・終了
nnoremap <Leader>w :w<CR>
nnoremap <Leader>q :q<CR>

" ウィンドウ移動（Ctrl+hjkl）
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" ターミナルモードでのウィンドウ移動
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l

" NERDTree トグル
nnoremap <D-b> :NERDTreeToggle<CR>
