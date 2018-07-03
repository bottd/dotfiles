set nocompatible
filetype off
set nobackup

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VudleVim/Vundle.vim'   " Plugins here
Plugin 'ErichDonGubler/vim-sublime-monokai'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-surround'
Plugin 'pangloss/vim-javascript'
call vundle#end()
filetype plugin indent on

"autocmd vimenter * NERDTree "Make NERDTree auto open
"autocmd StdinReadPre * let s:std_in=1   "Make NERDTree run when vim opened without file selected
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif "Auto exit NERDTree when it is last window

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
"Autosave
autocmd InsertLeave * :update

"Custom binds
nmap 8 :NERDTreeToggle<CR>
" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>
