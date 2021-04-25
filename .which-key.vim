" Map leader to which_key
nnoremap <silent> <leader> :silent WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :silent <c-u> :silent WhichKeyVisual '<Space>'<CR>

" Create map to add keys to
let g:which_key_map =  {}
" Define a separator
let g:which_key_sep = '→'
set timeoutlen=500


" Not a fan of floating windows for this
let g:which_key_use_floating_win = 0

" Change the colors if you want
highlight default link WhichKey          Operator
highlight default link WhichKeySeperator DiffAdded
highlight default link WhichKeyGroup     Identifier
highlight default link WhichKeyDesc      Function

" Hide status line
autocmd! FileType which_key
autocmd  FileType which_key set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 noshowmode ruler

" Single mappings
let g:which_key_map['e'] = [ ':e $MYVIMRC',         'Edit .vimrc' ]
let g:which_key_map['w'] = [ ':e ~/.which-key.vim', 'Edit .which-key.vim' ]
let g:which_key_map['.'] = [ ':source $MYVIMRC',    'Source .vimrc' ]
let g:which_key_map["'"] = [ ':NERDTreeToggle',     'NerdTree' ]
let g:which_key_map['f'] = [ ':Files',              'search files' ]
let g:which_key_map['-'] = [ ':new',                'hsplit']
let g:which_key_map['n'] = [ ':Startify',           'start screen' ]
let g:which_key_map['T'] = [ ':Rg',                 'search text' ]
let g:which_key_map['\'] = [ ':vnew',               'vsplit']
let g:which_key_map['j'] = [':tabprevious',         'previos tab']
let g:which_key_map['k'] = [':tabnext',             'next tab']
let g:which_key_map['='] = ['<C-W>=',               'balance windows']
let g:which_key_map['u'] = [':UndotreeToggle',      'toggle undo tree']
let g:which_key_map['a'] = ['<C-^>',                'alternate file']


" let g:which_key_map['z'] = [ 'Goyo'                       , 'zen' ]

" r is for resize
let g:which_key_map.r = {
      \ 'name' : '+Resize-windows',
      \ 'l' : [':vertical resize +5', 'increase width'],
      \ 'h' : [':vertical resize -5', 'decrease width'],
      \ 'k' : [':resize +5',          'increase height'],
      \ 'j' : [':resize -5',          'decrease height'],
      \ '=' : ['<C-W>=',              'equalize width and height'],
      \ 'w' : ['<C-W>|',              'set max width'],
      \ 'e' : ['<C-W>_',              'set max height'],
      \ 'm' : [':MaximizerToggle',    'toggle maximize'],
      \  }

" d is for debug
let g:which_key_map.d = {
      \ 'name' : '+Debug',
      \ 'e' : [':call vimspector#Reset()',        'exit debug mode'],
      \ 'l' : [':call vimspector#StepInto()',     'step into'],
      \ 'j' : [':call vimspector#StepOver()',     'step over'],
      \ 'k' : [':call vimspector#StepOut()',      'step out'],
      \ 'r' : [':call vimspector#Restart()',      'restart debugging'],
      \ 'c' : [':call vimspector#Continue()',     'continue'],
      \ 'rc' : [':call vimspector#RunToCursor()', 'run to cursor'],
      \ }
      " \ 'c' : [':call GoToWindow(g:vimspector_session_windows.code)', 'focus on code'],
      " \ 't' : [':call GotoWindow(g:vimspector_session_windows.tagpage)',     ''],
      " \ 'v' : [':call GotoWindow(g:vimspector_session_windows.variables)',   ''],
      " \ 'w' : [':call GotoWindow(g:vimspector_session_windows.watches)',     ''],
      " \ 's' : [':call GotoWindow(g:vimspector_session_windows.stack_trace)', ''],
      " \ 'o' : [':call GotoWindow(g:vimspector_session_windows.output)',      ''],

let g:which_key_map.d.b = {
      \ 'p' : [':call vimspector#ToggleBreakPoint()', 'toggle breakpoint'],
    \}

" s is for search
let g:which_key_map.s = {
      \ 'name' : '+search',
      \ '/' : [':History/',  'history'],
      \ ';' : [':Commands',  'commands'],
      \ 'a' : [':Ag',        'text Ag'],
      \ 'b' : [':BLines',    'current buffer'],
      \ 'B' : [':Buffers',   'open buffers'],
      \ 'c' : [':Commits',   'commits'],
      \ 'C' : [':BCommits',  'buffer commits'],
      \ 'f' : [':Files',     'files'],
      \ 'g' : [':GFiles',    'git files'],
      \ 'G' : [':GFiles?',   'modified git files'],
      \ 'h' : [':History',   'file history'],
      \ 'H' : [':History:',  'command history'],
      \ 'l' : [':Lines',     'lines'],
      \ 'm' : [':Marks',     'marks'],
      \ 'M' : [':Maps',      'normal maps'],
      \ 'p' : [':Helptags',  'help tags'],
      \ 'P' : [':Tags',      'project tags'],
      \ 's' : [':Snippets',  'snippets'],
      \ 'S' : [':Colors',    'color schemes'],
      \ 't' : [':Rg',        'text Rg'],
      \ 'T' : [':BTags',     'buffer tags'],
      \ 'w' : [':Windows',   'search windows'],
      \ 'y' : [':Filetypes', 'file types'],
      \ 'z' : [':FZF',       'FZF'],
      \ }

" S is for Session
let g:which_key_map.S = {
      \ 'name' : '+Session',
      \ 's' : [':mksession!',         'save session'],
      \ 'r' : [':source Session.vim', 'restore session'],
      \ }

" t is for tabs
let g:which_key_map.t = {
      \ 'name' : '+Tab',
      \ 'n' : [':tabnew',      'new tab'],
      \ 'c' : [':tabclose',    'close tab'],
      \ 'C' : [':tabonly',     'close every other tab'],
      \ 'j' : [':tabprevious', 'previos tab'],
      \ 'k' : [':tabnext',     'next tab'],
      \ 'h' : [':tabmove 0',   'move to beginning'],
      \ ',' : [':tabmove -1',  'move left'],
      \ '.' : [':tabmove +1',  'move right'],
      \ 'l' : [':tabmove $',   'move to end'],
      \ }

" g is for git
let g:which_key_map.g = {
      \ 'name' : '+git',
      \ 'B' : [':GBrowse',              'view in browser'],
      \ 'd' : [':Git diff',             'diff'],
      \ 'D' : [':Git diff --staged',    'diff staged'],
      \ 'c' : [':GBranches',            'checkout'],
      \ 'g' : [':G',                    'summary'],
      \ 'f' : [':GitGutterFold',        'fold'],
      \ 'j' : [':GitGutterNextHunk',    'next hunk'],
      \ 'k' : [':GitGutterPrevHunk',    'prev hunk'],
      \ 'a' : [':diffget //3',          'diffget from left'],
      \ ';' : [':diffget //2',          'diffget from right'],
      \ 'l' : [':Commits',              'pretty logs'],
      \ 'L' : [':Git log',              'log'],
      \ 'p' : [':GitGutterPreviewHunk', 'preview hunk'],
      \ 's' : [':GitGutterStageHunk',   'stage hunk'],
      \ 'S' : [':Gstatus',              'status'],
      \ 'u' : [':GitGutterUndoHunk',    'undo hunk'],
      \ }

" " b is for buffer
" let g:which_key_map.b = {
"       \ 'name' : '+buffer',
"       \ 'n' : [':bnext',               'next-buffer'],
"       \ 'p' : [':bprevious',           'previous-buffer'],
"       \ '?' : [':Buffers',             'fzf-buffer'],
"       \ }
"       \ '>' : [':BufferMoveNext',     'move next'],
"       \ '<' : [':BufferMovePrevious', 'move prev'],
"       \ 'b' : [':BufferPick',         'pick buffer'],
"       \ 'd' : [':BufferClose',        'delete-buffer'],
"

" Register which key map
call which_key#register('<Space>', "g:which_key_map")
