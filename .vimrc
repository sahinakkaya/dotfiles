" marks in this file
" p -> plugins
" s -> custom set's
set nocompatible              " be iMproved, required
filetype off                  " required
set number
set path+=**
set clipboard=unnamedplus
set encoding=UTF-8
let mapleader = "\<Space>"
set relativenumber
set incsearch
set tabstop=4
set updatetime=100
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

set foldmethod=indent
set foldlevel=99

set ic              " ignore case while searching
set smartcase       " ignore case if search pattern is lower case
                    " case-sensitive otherwise
                    "
set scrolloff=2

set mouse+=a
" if &term =~ '^xterm'
    " tmux knows the extended mouse mode
set ttymouse=xterm2
" endif


"toggle comment with //
nmap // gcc
vmap // gc


" Toggle relative line number
nmap <C-B><C-B> :set invrelativenumber<CR>

nmap gd :YcmCompleter GoToDefinition<CR>
nnoremap <leader>ghw :h <C-R>=expand("<cword>")<CR><CR>
nmap <C-m> :MaximizerToggle<CR>
inoremap kj <esc>
" Make Y consistent with C and D. See :help Y.
nnoremap Y y$


" Disable quote concealing in JSON files
let g:vim_json_conceal=0


let g:sneak#label = 1
let g:loaded_matchparen=1

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
" show cursorline only in active buffer

"keybindings for quickly switching windows
" nnoremap <C-J> <C-W>j
" nnoremap <C-K> <C-W>k
" nnoremap <C-L> <C-W>l
" nnoremap <C-H> <C-W>h

augroup CursorLine
    au!
    au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END


" toggle search with f3
nnoremap <F3> :nohlsearch<CR>
"trigger fzf with ctrl+f
nnoremap <silent> <C-f> :Files<CR>
"fzf but for git files.
silent! nmap <C-P> :GFiles<CR>
let g:fzf_colors = {
	\ 'fg':      ['fg', 'GruvboxGray'],
	\ 'bg':      ['bg', 'Normal'],
	\ 'hl':      ['fg', 'GruvboxRed'],
	\ 'fg+':     ['fg', 'GruvboxGreen'],
	\ 'bg+':     ['bg', 'GruvboxBg1'],
	\ 'hl+':     ['fg', 'GruvboxRed'],
	\ 'info':    ['fg', 'GruvboxOrange'],
	\ 'prompt':  ['fg', 'GruvboxBlue'],
	\ 'header':  ['fg', 'GruvboxBlue'],
	\ 'pointer': ['fg', 'Error'],
	\ 'marker':  ['fg', 'Error'],
	\ 'spinner': ['fg', 'Statement'],
	\ }
let g:fzf_layout = {'window': {'width': 0.8, 'height': 0.8} }
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -l'
let $FZF_DEFAULT_OPTS='--reverse  --bind change:top'
" Quickly insert an empty new line without entering insert mode
"nnoremap <Leader>o o<Esc>
"nnoremap <Leader>O O<Esc>


set t_Co=256
call vundle#begin()

Plugin 'airblade/vim-gitgutter'
Plugin 'altercation/vim-colors-solarized'
"Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'dense-analysis/ale'
"Plugin 'ErichDonGubler/vim-sublime-monokai'
Plugin 'flazz/vim-colorschemes'
"Plugin 'git://git.wincent.com/command-t.git'
Plugin 'gko/vim-coloresque'
Plugin 'gruvbox-community/gruvbox'
Plugin 'haya14busa/incsearch.vim'
Plugin 'junegunn/vim-easy-align'
Plugin 'justinmk/vim-sneak'
Plugin 'kana/vim-textobj-line'
Plugin 'kana/vim-textobj-user'
Plugin 'lepture/vim-jinja'
Plugin 'liuchengxu/vim-which-key'
"rainbow parenthesis
Plugin 'luochen1990/rainbow'
Plugin 'mbbill/undotree'
"muti cursor vim
Plugin 'mg979/vim-visual-multi'
Plugin 'mhinz/vim-startify'
" -------------------------------------look at this
Plugin 'patstockwell/vim-monokai-tasty'
"Plugin 'preservim/nerdcommenter'
Plugin 'preservim/nerdtree'
"Plugin 'preservim/syntastic' ----------- look at this
Plugin 'puremourning/vimspector'
Plugin 'stsewd/fzf-checkout.vim'
Plugin 'szw/vim-maximizer'
"Plugin 'rafi/awesome-vim-colorschemes'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"write html code faster
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'ryanoasis/vim-devicons'
" foldign for python
"Plugin 'tmhedberg/SimpylFold'
"desparate
"desperate
"
Plugin 'tpope/vim-abolish'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-obsession'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'
Plugin 'tpope/vim-rhubarb'
Plugin 'tomtom/tcomment_vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'vim-scripts/indentpython.vim'
Plugin 'VundleVim/Vundle.vim'
"Plugin 'xuyuanp/nerdtree git-plugin'
Plugin 'ycm-core/YouCompleteMe'
Plugin 'Yggdroot/indentLine'
call vundle#end()            " required
call plug#begin()
"Plug 'luochen1990/rainbow'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()

let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': [
\       'add_blank_lines_for_python_control_statements',
\       'black',
\       'isort',
\  ],
\  'json': [
\      'fixjson' ,
\  ],
\  'jinja.html': ['tidy'],
\}

let g:ale_fix_on_save = 1

source $HOME/.which-key.vim
" source $HOME/rotate.vim
nmap <silent> <C-e> <Plug>(ale_next_wrap)

" Disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed = 1

set backup		" keep a backup file (restore to previous version)
set swapfile
set dir=~/.vim/tmp
set undodir=~/.vim/undo
set backupdir=~/.vim/backup
if has('persistent_undo')
  set undofile	" keep an undo file (undo changes after closing)
endif

let g:gruvbox_italic=1
set background=dark
colorscheme gruvbox

filetype plugin indent on
" show existing tab with 4 spaces width
augroup vimrcEx
    au!
    " For all text files set 'textwidth' to 78 characters.
    autocmd FileType text setlocal textwidth=78
augroup END


" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif

"automatically start nerdtree when vim is opened
"autocmd vimenter * NERDTree
"ignore some files and dirs in nerdtree
let NERDTreeIgnore = ['\.py[cod]$', '\.egg$', '\.o$', '\~$', '__pycache__$', '\.egg-info$', 'node_modules$']
let NERDTreeDirArrowExpandable = "\u00a0" " make arrows invisible
let NERDTreeDirArrowCollapsible = "\u00a0" " make arrows invisible
let g:NERDTreeMapJumpNextSibling = '<Nop>'
let g:NERDTreeMapJumpPrevSibling = '<Nop>'


"exclude files and directories using Vim's wildignore
set wildmenu
set wildmode=longest,list
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe  " Windows
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/android/*
set wildignore+=**/ios/*
set wildignore+=**/.git/*




let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_always_populate_location_list = 1
let g:ycm_key_detailed_diagnostics = ''

let g:indentLine_concealcursor = 'inc'
let g:indentLine_conceallevel = 2

let g:airline_powerline_fonts = 1
let g:airline_theme='deus'
let g:airline#extensions#tabline#enabled = 1 " Use the airline tabline (replacement for buftabline)
let g:airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#show_tabs = 1
let g:airline#extensions#tabline#show_tab_nr = 0
let g:airline#extensions#tabline#show_tab_type = 0
let g:airline#extensions#tabline#close_symbol = '×'
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#obsession#enabled = 1
let g:airline#extensions#obsession#indicator_text = '|🔴 REC|'
" let g:airline#extensions#obsession#indicator_text = '<✏️ >'

let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle
"let g:ale_sign_warning = '⚠️⚠️'
" let g:ale_sign_error = "◉"
let g:ale_sign_warning = " ◉"
let g:ale_sign_error = ' ✗'
" let g:ale_sign_error = '•'
" let g:ale_sign_warning = '•'
highlight clear SignColumn
highlight ALEErrorSign ctermfg=196 guifg=#C30500
highlight ALEWarningSign ctermfg=214 guifg=#ED6237

" git gutter
let g:gitgutter_sign_added = '▌'
let g:gitgutter_sign_modified = '▌'
let g:gitgutter_sign_removed = '▁'
let g:gitgutter_sign_removed_first_line = '▌'
let g:gitgutter_sign_modified_removed = '▌'
let g:gitgutter_map_keys = 1
let g:gitgutter_realtime = 1
let g:gitgutter_preview_win_floating = 1
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)
highlight GitutterDelete guifg=#F97CA9
highlight GitGutterAdd    guifg=#BEE275
highlight GitGutterChange guifg=#96E1EF
highlight GitGutterAdd    guifg=#009900 ctermfg=2
highlight GitGutterChange ctermfg=3
highlight GitGutterDelete ctermfg=1
highlight GitGutterChangeDelete ctermfg=4

" vimspector
let g:vimspector_enable_mappings = 'HUMAN'
" packadd! vimspector
nnoremap <leader>dd :call vimspector#Launch()<CR>
let g:which_key_map.d.d = 'launch debugging'

" incsearch
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
