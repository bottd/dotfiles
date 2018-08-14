"-----------------------------Required settings-----------------------------

set nocompatible
filetype off
set mouse=a

"---------------------------------Plugins----------------------------------

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'bling/vim-bufferline'
Plugin 'blueyed/vim-diminactive'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'ErichDonGubler/vim-sublime-monokai'
Plugin 'itchyny/lightline.vim'
Plugin 'pangloss/vim-javascript'
Plugin 'scrooloose/nerdtree'
Plugin 'sheerun/vim-polyglot'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'VudleVim/Vundle.vim'

call vundle#end()
filetype plugin indent on

"--------------------------Color scheme settings---------------------------

colorscheme sublimemonokai
syntax enable
set background=dark
set t_Co=256

"----------------------Javascript syntax highligting-----------------------

let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_ngdoc = 1

"------------------------------Misc settings-------------------------------

set shiftwidth=0
set tabstop=2
set expandtab
set showmatch
set number
set relativenumber
set encoding=utf-8
set nobackup                             " no backup files
set nowritebackup                        " don't backup file while editing
set noswapfile                           " don't create swapfiles for new buffers
set updatecount=0                        " Don't try to write swapfiles after some number of updates
set backupskip=/tmp/*,/private/tmp/*"    " can edit crontab files
set timeoutlen=150
set cursorline
set scrolloff=4
set vb
set clipboard=unnamed
autocmd InsertLeave * :update
filetype plugin indent on

"------------------------------Custom binds-------------------------------

map <C-n> :NERDTreeToggle<CR>
let mapleader = "\<Space>"
let g:tmux_navigator_save_on_switch = 2

"----------------------Remove trailing spaces on save---------------------

autocmd BufWritePre * :%s/\s\+$//e

"--------------------------------Lightline--------------------------------

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
  \  'right': [ ['gitbranch'] ],
  \ }
set showtabline=2  " Show tabline
set guioptions-=e  " Don't use GUI tabline

"------------------------------Ctrl P filter------------------------------

set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ }
