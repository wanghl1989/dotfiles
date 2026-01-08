syntax on
set nocompatible
set autoread
set mouse=a
set magic
set title
set titlestring="Vim - %t"
set nobackup
set encoding=utf-8

set number
set relativenumber
set cursorline
set wrap
set showcmd
set showmode
set showtabline=2
set linebreak
set laststatus=2
set t_Co=256

if version >= 603
        set helplang=cn
endif

set showmatch
set hlsearch
set ignorecase
set incsearch
set smartcase

set expandtab
set smartindent


set undofile
set undodir=~/.vim/undo
set clipboard=unnamedplus

let mapleader = " "
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>x :x<CR>
nnoremap gl $
nnoremap gh ^

nnoremap <leader>nh :noh<CR>
nnoremap <leader>e :e .<CR>
nnoremap <S-h> :bprevious<CR>
nnoremap <S-l>l :bnext<CR>

