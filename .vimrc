set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'   " Plugins here
Plugin 'ErichDonGubler/vim-sublime-monokai'
Plugin 'scrooloose/nerdtree'
call vundle#end()
filetype plugin indent on

"autocmd vimenter * NERDTree "Make NERDTree auto open
"autocmd StdinReadPre * let s:std_in=1   "Make NERDTree run when vim opened without file selected
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif "Auto exit NERDTree when it is last window

syntax on
colorscheme sublimemonokai

"Misc settings
set shiftwidth=0
set tabstop=4
set expandtab
set relativenumber

"Custom binds
nmap 8 :NERDTreeToggle<CR>
