"=============================================================================
" vimrc --- Entry file for vim
" Copyright (c) 2016-2017 Shidong Wang & Contributors
" Author: Shidong Wang < wsdjeg at 163.com >
" URL: https://spacevim.org
" License: GPLv3
"=============================================================================

" Note: Skip initialization for vim-tiny or vim-small.
if 1
    execute 'source' fnamemodify(expand('<sfile>'), ':h').'/config/main.vim'
endif
" vim:set et sw=2
let g:spacevim_automatic_update = 1
let g:ackprg = 'ag --nogroup --nocolor --column'
nmap <F8> :TagbarToggle<CR>
set termguicolors
set background=dark
let mapleader=','
autocmd bufnewfile *.py :0r ~/.vim_back/template/py/pythontmp.txt


nnoremap z/ :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>
function! AutoHighlightToggle()
  let @/ = ''
  if exists('#auto_highlight')
    au! auto_highlight
    augroup! auto_highlight
    setl updatetime=4000
    echo 'Highlight current word: off'
    return 0
  else
    augroup auto_highlight
      au!
      au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
    augroup end
    setl updatetime=100
    echo 'Highlight current word: ON'
    return 1
  endif
endfunction

" HiCursorWords -- Highlights words under the cursor.
"
" Maintainer: Shuhei Kubota <kubota.shuhei+vim@gmail.com>
" Description:
"   This script highlights words under the cursor like many IDEs.
"
"   This doesn't provide scope-aware highlighting nor language specific one.
"   You can control highlighting by highlighting group names.
"
" Variables:
"
"   (A right hand side value is a default value.)
"
"   g:HiCursorWords_delay = 200
"       A delay for highlighting in milliseconds.
"       Smaller value may cause your machine slow down.
"
"   g:HiCursorWords_hiGroupRegexp = ''
"       If empty, all words are highlighted.
"       If not empty, only the specified highlight group is highlighted.
"       (my memo: 'Identifier\|vimOperParen')
"
"       To investigate highlight group name, the next variable may help you.
"
"   g:HiCursorWords_debugEchoHiName = 0
"       If not 0, echoes the highlight group name under the cursor.
"
"   g:HiCursorWords_visible = 1
"       Set to 0 in vimrc to startup with HiCursorWords disabled
"
"   g:HiCursorWords_style
"       Set cursor-word style
"
"   or
"
"   g:HiCursorWords_linkStyle
"       Set cursor-word style for linking
"
" Hightlight groups:
"
"   (Do :highlight! as you like.)
"
"   WordUnderTheCursor
"
"
" Source this file and put the following line in your vimrc to
" toggle auto-highlighting of the word under the cursor.
"map <F5> :call HiCursorWords_toggle()<cr>


if !exists('g:HiCursorWords_delay')
    let g:HiCursorWords_delay = 200
endif

if !exists('g:HiCursorWords_hiGroupRegexp')
    let g:HiCursorWords_hiGroupRegexp = ''
endif

if !exists('g:HiCursorWords_debugEchoHiName')
    let g:HiCursorWords_debugEchoHiName = 0
endif

if !exists('g:HiCursorWords_visible')
    let g:HiCursorWords_visible = 1
endif

if !exists('g:HiCursorWords_style') && !exists('g:HiCursorWords_linkStyle')
    let g:HiCursorWords_linkStyle='Underlined'
endif

if g:HiCursorWords_visible
    if exists('g:HiCursorWords_style')
        exec 'highlight! WordUnderTheCursor ' . g:HiCursorWords_style
    elseif exists('g:HiCursorWords_linkStyle')
        exec 'highlight! link WordUnderTheCursor '.  g:HiCursorWords_linkStyle
    endif
else
    highlight! link WordUnderTheCursor NONE
endif

augroup HiCursorWords
    autocmd!
    autocmd  CursorMoved,CursorMovedI  *  call s:HiCursorWords__startHilighting()
    autocmd  WinLeave * call s:HiCursorWords__stopHilighting()
augroup END

function! s:HiCursorWords__getHiName(linenum, colnum)
    let hiname = synIDattr(synID(a:linenum, a:colnum, 0), "name")
    let hiname = s:HiCursorWords__resolveHiName(hiname)
    return hiname
endfunction

function! s:HiCursorWords__resolveHiName(hiname)
    redir => resolved
    silent execute 'highlight ' . a:hiname
    redir END

    if stridx(resolved, 'links to') == -1
        return a:hiname
    endif

    return substitute(resolved, '\v(.*) links to ([^ ]+).*$', '\2', '')
endfunction

function! s:HiCursorWords__getWordUnderTheCursor(linestr, linenum, colnum)
    "let word = substitute(a:linestr, '.*\(\<\k\{-}\%' . a:colnum . 'c\k\{-}\>\).*', '\1', '') "expand('<word>')
    let word = matchstr(a:linestr, '\k*\%' . a:colnum . 'c\k\+')
    if word == ''
        return ''
    endif
    return '\V\<' . word . '\>'
endfunction

function! s:HiCursorWords__execute()
    if exists("w:HiCursorWords__matchId")
        call matchdelete(w:HiCursorWords__matchId)
        unlet w:HiCursorWords__matchId
    endif

    let linestr = getline('.')
    let linenum = line('.')
    let colnum = col('.')

    if g:HiCursorWords_debugEchoHiName
        echo s:HiCursorWords__getHiName(linenum, colnum)
    endif

    let word = s:HiCursorWords__getWordUnderTheCursor(linestr, linenum, colnum)
    if strlen(word) != 0
        if strlen(g:HiCursorWords_hiGroupRegexp) != 0
                    \ && match(s:HiCursorWords__getHiName(linenum, colnum), g:HiCursorWords_hiGroupRegexp) == -1
            return
        endif
        let w:HiCursorWords__matchId = matchadd('WordUnderTheCursor', word, 0)
    endif
endfunction

function! s:HiCursorWords__startHilighting()
    let b:HiCursorWords__oldUpdatetime = &updatetime
    let &updatetime = g:HiCursorWords_delay
    augroup HiCursorWordsUpdate
        autocmd!
        autocmd CursorHold,CursorHoldI  *
                    \ if exists('b:HiCursorWords__oldUpdatetime') | let &updatetime = b:HiCursorWords__oldUpdatetime | endif
                    \ | call s:HiCursorWords__execute()
    augroup END
endfunction

" Steven Lu: Add functionality to prevent the HCW styles being present in
" a vim window that is out of focus. For example, it confuses and interferes
" with vim-mark styles
function! s:HiCursorWords__stopHilighting()
    if exists("w:HiCursorWords__matchId")
        call matchdelete(w:HiCursorWords__matchId)
        unlet w:HiCursorWords__matchId
    endif
endfunction

function! HiCursorWords_toggle()
    if g:HiCursorWords_visible == 0
        highlight! link WordUnderTheCursor Underlined
        let g:HiCursorWords_visible = 1
    else
        highlight! link WordUnderTheCursor NONE
        let g:HiCursorWords_visible = 0
    endif
endfunction

map <F5> :call HiCursorWords_toggle()<cr>
