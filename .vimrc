set nocompatible
filetype off
set nobackup

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VudleVim/Vundle.vim'   " Plugins here
Plugin 'ErichDonGubler/vim-sublime-monokai'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-fugitive'
Plugin 'pangloss/vim-javascript'
Plugin 'itchyny/lightline.vim'
call vundle#end()
filetype plugin indent on

"autocmd StdinReadPre * let s:std_in=1   "Make NERDTree run when vim opened without file selected
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif "Auto exit NERDTree when it is last window
" FONTS THINGS
set guifont=Inconsolata\ for\ Powerline:h15
let g:Powerline_symbols = 'fancy'
set encoding=utf-8
set t_Co=256
set fillchars+=stl:\ ,stlnc:\
set term=xterm-256color
set termencoding=utf-8
"Color scheme settings
syntax on
colorscheme sublimemonokai
"Javascript syntax highligting
let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_ngdoc = 1

"Misc settings
set shiftwidth=0
set tabstop=4
set expandtab
set relativenumber
set encoding=utf-8
"Autosave
autocmd InsertLeave * :update

"Custom binds
nmap 8 :NERDTreeToggle<CR>
nmap Y :y $
" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

"Lightline
set laststatus=2
let g:lightline = {
  \   'colorscheme': 'one',
  \   'active': {
  \     'left':[ [ 'mode', 'paste' ],
  \              [ 'gitbranch', 'readonly', 'filename', 'modified' ]
  \     ]
  \   },
	\   'component': {
	\     'lineinfo': ' %3l:%-2v',
	\   },
  \   'component_function': {
  \     'gitbranch': 'fugitive#head',
  \   }
  \ }
let g:lightline.separator = {
	\   'left': '', 'right': ''
  \}
let g:lightline.subseparator = {
	\   'left': '', 'right': ''
  \}

let g:lightline.tabline = {
  \   'left': [ ['tabs'] ],
  \   'right': [ ['close'] ]
  \ }
set showtabline=2  " Show tabline
set guioptions-=e  " Don't use GUI tabline

