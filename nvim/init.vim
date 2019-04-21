"-----------------------------Required settings-----------------------------

if &compatible
  set nocompatible               " Be iMproved
endif

"------------------------------------Dein-----------------------------------

":DeinUpdate to update plugins
"call coc#util#install() to update CoC

set runtimepath+=/Users/drakebott/.config/nvim/dein/repos/github.com/Shougo/dein.vim
if dein#load_state('/Users/drakebott/.config/nvim/dein')
  call dein#begin('/Users/drakebott/.config/nvim/dein')
  call dein#add('/Users/drakebott/.config/nvim/dein/repos/github.com/Shougo/dein.vim')

  "Plugins here
  call dein#add('cakebaker/scss-syntax.vim')
  call dein#add('christoomey/vim-tmux-navigator')
  call dein#add('djoshea/vim-autoread')
  call dein#add('ervandew/supertab')
	call dein#add('iCyMind/NeoSolarized')
  call dein#add('itchyny/lightline.vim')
  call dein#add('leafgarland/typescript-vim')
  call dein#add('mxw/vim-jsx')
  call dein#add('neoclide/coc.nvim', {'merge':0, 'build': './install.sh nightly'})
  call dein#add('pangloss/vim-javascript')
  call dein#add('posva/vim-vue')
  call dein#add('prettier/vim-prettier')
  call dein#add('scrooloose/nerdtree')
  call dein#add('Shougo/deol.nvim')
  call dein#add('tpope/vim-commentary')
  call dein#add('tpope/vim-fugitive')
  call dein#add('tpope/vim-surround')
  call dein#add('wsdjeg/dein-ui.vim')

 " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on

"------------------------------Color scheme---------------------------------

let hour = strftime("%H")        "Solarized light between 6 AM and 6 PM
if 6 <= hour && hour < 18
  set background=light
else
  set background=dark
endif
syntax enable
colorscheme NeoSolarized
set termguicolors

"-------------------------------Misc settings-------------------------------

set shiftwidth=0
set tabstop=2
set expandtab
set showmatch
set number
set encoding=utf-8
set nobackup
set nowritebackup
set noswapfile
set updatecount=0
set backupskip=/tmp/*,/private/tmp/*"
set timeoutlen=150
set cursorline
set scrolloff=4
set clipboard=unnamed
filetype plugin indent on
let g:SuperTabDefaultCompletionType = "<c-n>"
let g:tmux_navigator_save_on_switch = 2
let g:prettier#config#bracket_spacing = 'true'
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

"---------------------------------Binds-------------------------------------

map <SPACE> <leader>
map <C-n> :NERDTreeToggle<CR>


"-----------------------Remove trailing spaces on save----------------------

autocmd BufWritePre * :%s/\s\+$//e

"-------------------------------Lightline-----------------------------------

set laststatus=2
let g:lightline = {
  \   'colorscheme': 'solarized',
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

"---------------------------------------------------------------------------
