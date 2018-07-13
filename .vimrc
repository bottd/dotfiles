"make a .tmux.conf file
"Set leader key to space
"install karabiner and set hold down capslock to be a control input

set nocompatible
filetype off

"Enable mouse
set mouse=a

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VudleVim/Vundle.vim'   " Plugins here
Plugin 'ErichDonGubler/vim-sublime-monokai'
Plugin 'altercation/vim-colors-solarized'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-fugitive'
Plugin 'pangloss/vim-javascript'
Plugin 'itchyny/lightline.vim'
Plugin 'bling/vim-bufferline'
Plugin 'sheerun/vim-polyglot'
call vundle#end()
filetype plugin indent on

"Color scheme settings
colorscheme sublimemonokai
syntax enable
set background=dark
set t_Co=256

"Javascript syntax highligting
let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_ngdoc = 1

"Misc settings
set shiftwidth=0
set tabstop=2
set expandtab
set number
set relativenumber
set encoding=utf-8
set nobackup                             " no backup files
set nowritebackup                        " don't backup file while editing
set noswapfile                           " don't create swapfiles for new buffers
set updatecount=0                        " Don't try to write swapfiles after some number of updates
set backupskip=/tmp/*,/private/tmp/*"    " can edit crontab files
set timeoutlen=150
autocmd InsertLeave * :update
filetype plugin indent on
set cursorline
set scrolloff=4
set vb
set clipboard=unnamed

"Custom binds
nmap 8 :NERDTreeToggle<CR>
let mapleader = " "

" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

"Trailing spaces highlighting
highlight ExtraWhitespace ctermbg=1 guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

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

let g:lightline.tabline = {
  \   'left': [ ['tabs'] ],
  \   'right': [ ['close'] ]
  \ }
set showtabline=2  " Show tabline
set guioptions-=e  " Don't use GUI tabline
