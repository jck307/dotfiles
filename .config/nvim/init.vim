
"  nvim config by jack
"  https://github.com/jackiboi307/dotfiles
"
"     ,;,         :.
"   ,::;::        :cc,
"  ::c:::::.      :cccc 
"  cccc:;;;;.     cllll 
"  ccccc';;;;;.   cllll 
"  ccccc  :;;;;.  coooo 
"  lllll   ':::::.loooo 
"  lllll    `::::::oooo 
"  ooooo      ':::::odd 
"  'oooo       ':::::o: 
"    'oc         :::::´
"      '          `:´  

"""""""""""""""""""" Settings

set number
windo set scrolloff=1
set nofoldenable
set noshowmode
" set linebreak
set shiftround

" set autochdir
autocmd BufEnter * silent! lcd %:p:h

" Tab settings:
filetype plugin on
filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab
set sw=4 sts=4 et

set laststatus=2

"""""""""""""""""""" Colors

colorscheme retrobox
source /home/jack/.config/nvim/colors.vim
hi! Normal guibg=NONE ctermbg=NONE

"""""""""""""""""""" Keybindings

tnoremap <Esc> <C-\><C-n>
nnoremap Q @q
nnoremap <C-i> i<Ins>

noremap <Tab> :tabnext<CR>
noremap <S-Tab> :tabprevious<CR>
noremap TT :tabedit<CR>

" nnoremap <F5> :vsplit <bar> :term python ~/Programmering/vim-run-py.py % <CR> a
" inoremap <silent> <F5> <Esc> :execute ':vsplit <bar> :term python "~/Programmering/vim-run-py.py %"' <bar> :startinsert <CR> a

" nnoremap <silent> <C-s> :w<CR>
" inoremap <silent> <C-s> <Esc>:w<CR>a

" nnoremap ! :!

noremap + $
noremap 0 ^
noremap = 0

nnoremap J J$

vnoremap za zf<Esc>

nnoremap <C-CR> :noh<CR>
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

let s:chars = "[()[\\]{}<>'\"]"

function CharForward()
    call search(s:chars)
endfunction

function CharBackward()
    call search(s:chars, 'b')
endfunction

noremap ) <Cmd>call CharForward()<CR>
noremap ( <Cmd>call CharBackward()<CR>

" vmap <Space> <Esc>(lv)h

augroup NetrwMappings
    autocmd!
    autocmd FileType netrw nmap <buffer> l <CR>
    autocmd FileType netrw nmap <buffer> h 8G<CR>2j
augroup END

"""""""""""""""""""" Plugins

if ! empty(globpath(&rtp, 'autoload/plug.vim'))
    call plug#begin('~/.vim/plugged')
        " Dunno
        " Plug 'airblade/vim-rooter'
        Plug 'tpope/vim-commentary'
        Plug 'xolox/vim-misc'
        " Plug 'xolox/vim-session'
        " Plug 'kevinhwang91/rnvimr'
        " Plug 'kelly-lin/ranger.nvim'

        " Python
        " Plug 'vim-python/python-syntax'
        Plug 'tmhedberg/SimpylFold'

        " Folding
        Plug 'Konfekt/FastFold'
        Plug 'zhimsel/vim-stay'

        " Colorscemes
        " Plug 'morhetz/gruvbox'

        " Git
        Plug 'tpope/vim-fugitive'
        Plug 'airblade/vim-gitgutter'

        " Plug 'neoclide/coc.nvim', {'branch': 'release'}
        " Plug 'dense-analysis/ale'
        " Plug 'mhinz/vim-startify'
        " Plug 'vim-crystal/vim-crystal'

        Plug 'kevinhwang91/rnvimr'
    call plug#end()
endif

"""""""""""""""""""" Lua config

" lua require('init')

"""""""""""""""""""" Plugin configuration

nnoremap <silent> K :RnvimrToggle<CR>
let g:rnvimr_ranger_cmd = ['ranger', '--cmd=set column_ratios 3,4']
let g:rnvimr_enable_ex = 1
let g:rnvimr_enable_picker = 1
let g:rnvimr_edit_cmd = 'drop'

"""""""""""""""""""" Various custom stuff

augroup statusline
    autocmd!
    autocmd WinEnter,BufEnter * setlocal statusline=%#StatusActive#%F%r%m%=%3l:%-2c
    autocmd WinLeave,BufLeave * setlocal statusline=%#StatusInactive#%F%r%m%=%3l:%-2c
augroup end

function! SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc

" Custom tabline (from :h setting-tabline)
function MyTabLine()
    let s = ''
    for i in range(tabpagenr('$'))
        " select the highlighting
        if i + 1 == tabpagenr()
            let s ..= '%#TabLineSel#'
        else
            let s ..= '%#TabLine#'
        endif

        " set the tab page number (for mouse clicks)
        let s ..= '%' .. (i + 1) .. 'T'

        " the label is made by MyTabLabel()
        let s ..= ' %{MyTabLabel(' .. (i + 1) .. ')} '

        if i + 1 == tabpagenr()
            let s ..= '%m'
        endif
    endfor

    " after the last tab fill with TabLineFill and reset tab page nr
    let s ..= '%#TabLineFill#%T'

    " right-align the label to close the current tab page
    "if tabpagenr('$') > 1
    "    let s ..= '%=%#TabLine#%999Xclose'
    "endif

    return s
endfunction

function MyTabLabel(n)
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)

    let name = bufname(buflist[winnr - 1])
    let splitted = split(name, "/")

    if len(splitted) > 0
        let name = splitted[-1]
    endif

    if name == ''
        return '[New]'
    else
        return name
    endif
endfunction

set tabline=%!MyTabLine()

" Custom fold text (from SO)
fu! CustomFoldText(string)
    " get first non-blank line
    let fs = v:foldstart
    while getline(fs) =~ '^\s*$' | let fs = nextnonblank(fs + 1)
    endwhile
    if fs > v:foldend
        let line = getline(v:foldstart)
    else
        let line = substitute(getline(fs), '\t', repeat(' ', &tabstop), 'g')
    endif
    let pat  = matchstr(&l:cms, '^\V\.\{-}\ze%s\m')
    " remove leading comments from line
    let line = substitute(line, '^\s*'.pat.'\s*', '', '')
    " remove foldmarker from line
    let pat  = '\%('. pat. '\)\?\s*'. split(&l:fmr, ',')[0]. '\s*\d\+'
    let line = substitute(line, pat, '', '')

"   let line = substitute(line, matchstr(&l:cms,
"        \ '^.\{-}\ze%s').'\?\s*'. split(&l:fmr,',')[0].'\s*\d\+', '', '')

    if get(g:, 'custom_foldtext_max_width', 0)
    let w = g:custom_foldtext_max_width - &foldcolumn - (&number ? 8 : 0)
    else
    let w = winwidth(0) - &foldcolumn - (&number ? 8 : 0)
    endif
    let foldSize = 1 + v:foldend - v:foldstart
    let foldSizeStr = " " . foldSize . " lines "
    let foldLevelStr = '+'. v:folddashes
    let lineCount = line("$")
    if exists("*strwdith")
    let expansionString = repeat(a:string, w - strwidth(foldSizeStr.line.foldLevelStr))
    else
    let expansionString = repeat(a:string, w - strlen(substitute(foldSizeStr.line.foldLevelStr, ' ', 'x', 'g')))
    endif
    return line . expansionString . foldSizeStr . foldLevelStr
endf
set foldtext=CustomFoldText('\ ')

" https://github.com/vim-scripts/Rename2
command! -nargs=* -complete=file -bang Rename :call Rename("<args>", "<bang>")
function! Rename(name, bang)
    let l:curfile = expand("%:p")
    let l:curfilepath = expand("%:p:h")
    let l:newname = l:curfilepath . "/" . a:name
    let v:errmsg = ""
    silent! exe "saveas" . a:bang . " " . l:newname
    if v:errmsg =~# '^$\|^E329'
        if expand("%:p") !=# l:curfile && filewritable(expand("%:p"))
            silent exe "bwipe! " . l:curfile
            if delete(l:curfile)
                echoerr "Could not delete " . l:curfile
            endif
        endif
    else
        echoerr v:errmsg
    endif
    e
endfunction

" I don't remember what this is
augroup terminal_settings
    autocmd!

    " autocmd BufWinEnter,WinEnter term://* startinsert
    autocmd BufLeave term://* stopinsert

    " Ignore various filetypes as those will close terminal automatically
    " Ignore fzf, ranger, coc
    autocmd TermClose term://*
      \ if (expand('<afile>') !~ "fzf") && (expand('<afile>') !~ "ranger") && (expand('<afile>') !~ "coc") |
      \   call nvim_input('<CR>')  |
      \ endif
augroup END
