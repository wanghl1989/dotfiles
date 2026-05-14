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
set shortmess+=I
colorscheme habamax
set termguicolors

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
nnoremap <leader>ww :update<CR>
nnoremap <leader>wq :bdelete<CR>
nnoremap <leader>qq :q<CR>
nnoremap gl $
nnoremap gh ^
nnoremap yL y$
nnoremap yH y^
nnoremap cL c$
nnoremap cH c^
nnoremap vL v$
nnoremap vH v^
nnoremap dL d$
nnoremap dH d^

nnoremap <leader>nh :noh<CR>
nnoremap <leader>e :e .<CR>
nnoremap <leader>\| <C-w>v<CR>
nnoremap <leader>- <C-w>s<CR>

nnoremap <S-h> :bprevious<CR>
nnoremap <S-l> :bnext<CR>

nnoremap <C-h> <C-w>h<CR>
nnoremap <C-j> <C-w>j<CR>
nnoremap <C-k> <C-w>k<CR>
nnoremap <C-l> <C-w>l<CR>

vnoremap > >gv<CR>
vnoremap < <gv<CR>

vnoremap <S-j> <NOP>
vnoremap <S-k> <NOP>

let g:netrw_banner=0        " 关闭讨厌的顶部提示
let g:netrw_liststyle=3     " 树状显示文件
let g:netrw_winsize=25      " 文件树宽度 25%
let g:netrw_altv=1          " 垂直分栏打开文件
let g:netrw_browse_split=4  " 新建窗口打开文件

