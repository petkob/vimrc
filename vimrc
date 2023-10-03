" check :options and ':set all' to see what is configur[ed/able]
set nocompatible mouse=a
set history=1000

" ##########################################################################
" Help: h[elp] https://vimhelp.org/
" ##########################################################################
function! HelpWindow()
    if (&buftype == "help")
        :close
    else
        :vertical help
        :vertical resize +3
    endif
endfunction
inoremap <F1> <ESC> :call HelpWindow()<CR>
nnoremap <F1> :call HelpWindow()<CR>
cnoreabbrev <expr> h getcmdtype() == ":" && getcmdline() == "h" ? "vert h" : "h"

" ##########################################################################
" Presentation
" ##########################################################################
set cursorline cursorlineopt=both
augroup CursorLineOnlyInActiveWindow
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  autocmd WinLeave * setlocal nocursorline
augroup END
set showbreak=… " when a line is too long and reflows
set wrap linebreak " don't break words
set textwidth=120
call matchadd('ColorColumn', '\%81v', 100) " paint column 81 if text goes there
syntax enable " coloring
exec "set listchars=tab:\u25B8\u25B8,multispace:\uB7,leadmultispace:\uA0,trail:\uB7,nbsp:~"
set list " Show tabs, more than one space not in the beginning, and trailing spaces; see above
nmap <leader>l :set list!<CR> " toggle showing invisible spaces
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif " remember file position

" ##########################################################################
" Moving and scrolling: h, j, k, l; ^D, ^U; ^F, ^B; ^E, ^Y; z-, z+, z.
" ##########################################################################
set scrolloff=3 " number of screen lines to keep above and below the cursor
nmap <C-Up>   gkzz
nmap <C-Down> gjzz

" ##########################################################################
" Editing
" ##########################################################################
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab smarttab
set autoindent smartindent
filetype plugin indent on
nnoremap Y y$ " yank till EOL
set clipboard=unnamed " yanks into the system clipboard; works if "echo has('clipboard')" returns 1
vnoremap <C-S-Up>   :m '<-2<CR>gv=gv " move selection up
vnoremap <C-S-Down> :m '>+1<CR>gv=gv " move selection down
xnoremap <C-S-Left>  <gv " move selection left
xnoremap <C-S-Right> >gv " move selection right

" ##########################################################################
" Folding :help usr_28; zf, zd, zo, zc, zO, zC, zA
" ##########################################################################
set foldenable foldmethod=manual
autocmd BufWinLeave *.* mkview " folds outlast file closing
autocmd BufWinEnter *.* silent loadview

" ##########################################################################
" Line numbering
" ##########################################################################
highlight LineNr ctermfg=darkgrey ctermbg=black
set number
nmap <F2> :set nu! <CR>
imap <F2> <ESC> :set nu! <CR>i
nmap <M-F2> :set rnu! <CR>

" ##########################################################################
" Status line: https://vi.stackexchange.com/questions/20542/review-git-branch-in-statusline
" ##########################################################################
set laststatus=2 " statusline always on
let g:git_branch = ''
function! GetGitBranchName()
    let path = expand('%:h')
    if (path == '')
        return
    endif
    cd %:h
    silent let g:git_branch = system('git branch --show-current --no-color 2> /dev/null | tr -cd [:print:]')
    cd -
endfunction
autocmd BufEnter * call GetGitBranchName()

function! StatusLineGitBranch()
    if (g:git_branch == '')
        return ''
    else
        return "(".g:git_branch.")"
    endif
endfunction

set statusline=%{StatusLineGitBranch()}\%m\ %F\ %R\%y\ B#%n\ %{&fenc?&fenc:&encoding}\ %=%({0x%B}\ C:%c\ L:%l/%L\ %P%)
set showcmd

" ##########################################################################
" Search/Replace :help usr_27
" ##########################################################################
set ignorecase smartcase incsearch hlsearch nowrapscan
nnoremap <ESC> :nohlsearch<CR>
nnoremap S :%s//g<left><left>

" ##########################################################################
" Files: w[rite], sav[eas], wa[ll]
" ##########################################################################
set fileformats=unix,dos " use unix, but leave dos format files as they are
set autoread " when file is changed from outside
set path=.,** wildmenu
set wildmode=list:longest wildignore=*.gif,*.gz,*.img,*.jpg,*.lib,*.mp4,*.o,*.pdf,*.png,*.pyc,*.zip
set undofile undodir=~/.vim/undodir " undo even before last opening of the file
cnoremap w!! w !sudo tee % > /dev/null " save as root if no rights on file
cmap W w " in case shift was not released fast enough on writing

" ##########################################################################
" Netrw built in file explorer — <F1>:help; <CR>:enter/read; '-':up dir;d: new dir
" <Del>:remove; s:sort by; %:new file; R:rename
" ##########################################################################
let g:netrw_banner = 0 " I toggles banner showing
let g:netrw_browse_split = 4 " open in prior window
let g:netrw_altv = 1 " splits to the right
let g:netrw_liststyle = 3 " tree view
let g:netrw_list_hide = netrw_gitignore#Hide() " gh toggles hide
let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'
let g:netrw_winsize = 24
noremap <F3> <ESC> :Lexplore <CR> " open file explorer on the left

" ##########################################################################
" Buffers: e[dit], ene[w], fin[d]; bn[ext], bp[revious], bd[elete]; ls
" ##########################################################################
set hidden " hide buffers instead of closing them
nmap <M-Right> :bnext <CR> " movement between buffers; :bd closes
nmap <M-Left> :bprev <CR>

" ##########################################################################
" Windows: sp[lit], vs[plit]; Ctrl-Wsvwcqx=hljkHLJK
" ##########################################################################
set splitbelow splitright " split windows
set fillchars+=vert:\ "
nnoremap <C-h> <C-w>h " movement between windows
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
if bufwinnr(1) " TODO: some of these are redundant and have to be deleted
  nmap <M-Right> :vertical resize +1<CR>
  nmap <M-Left> :vertical resize -1<CR>
  nmap <M-Down> :resize +1<CR>
  nmap <M-Up> :resize -1<CR>
  map + <C-W>+
  map - <C-W>-
  map < <C-W><
  map > <C-W>>
  map = <C-W>= " equal window size
endif

" ##########################################################################
" Tabs: tabe[dit], tabnew, tabfind
" ##########################################################################
if tabpagenr()
  nnoremap H gT " previous tab
  nnoremap L gt " next tab
endif

" ##########################################################################
" Python shortcuts
" ##########################################################################
abbreviate pysh #!/usr/bin/env python3<CR>
map <F4> :%w !python3 <CR>
nmap <M-F4> :terminal %:p<CR>

" ##########################################################################
" Redraw screen if it gets garbled
" ##########################################################################
map <F5> <ESC> :redraw <CR>

" ##########################################################################
" Insert current date/time
" ##########################################################################
nnoremap <F6> "=strftime("%Y-%m-%d")<CR>P
inoremap <F6> <C-R>=strftime("%Y-%m-%d")<CR>
nnoremap <S-F6> "=strftime("%Y-%m-%d %H:%M:%S %z")<CR>P
inoremap <S-F6> <C-R>=strftime("%Y-%m-%d %H:%M:%S %z")<CR>

" ##########################################################################
" Terminals: ter[minal]
" ##########################################################################
" vim-powered terminal in split window
map <Leader>t :term ++close<cr>
tmap <Leader>t <c-w>:term ++close<cr>

" vim-powered terminal in new tab
map <Leader>T :tab term ++close<cr>
tmap <Leader>T <c-w>:tab term ++close<cr>

" ##########################################################################
" Plugins
" ##########################################################################
call plug#begin('~/.vim/plugged')
Plug 'mhinz/vim-signify' " show changed lines for files in a CVS
call plug#end()
set updatetime=100
highlight SignifySignAdd    ctermfg=DarkGreen  ctermbg=Black guifg=#00ff00 cterm=NONE gui=NONE
highlight SignifySignDelete ctermfg=Red    ctermbg=Black guifg=#ff0000 cterm=NONE gui=NONE
highlight SignifySignChange ctermfg=Yellow ctermbg=Black guifg=#ffff00 cterm=NONE gui=NONE
highlight SignColumn ctermbg=Black cterm=NONE guibg=NONE gui=NONE
