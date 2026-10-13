" ~/.vimrc  (WSL / Ubuntu, terminal Vim)

" --- Filetype detection + plugins ---
filetype plugin indent on
syntax on

" --- Indentation: 4 spaces, no real tabs ---
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set autoindent
set smartindent

" --- No .swp files ---
set noswapfile

" --- Snappy Esc / insert mode ---
set timeout timeoutlen=1000
set ttimeout ttimeoutlen=10

" --- Alt+j / Alt+k move the current line down / up ---
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

" --- Alt+1..6 jump to tab page 1..6 ---
nnoremap <A-1> 1gt
nnoremap <A-2> 2gt
nnoremap <A-3> 3gt
nnoremap <A-4> 4gt
nnoremap <A-5> 5gt
nnoremap <A-6> 6gt
inoremap <A-1> <Esc>1gt
inoremap <A-2> <Esc>2gt
inoremap <A-3> <Esc>3gt
inoremap <A-4> <Esc>4gt
inoremap <A-5> <Esc>5gt
inoremap <A-6> <Esc>6gt

" --- x / X delete a character without touching any register or the clipboard ---
nnoremap x "_x
nnoremap X "_X

" --- Clipboard: share the Windows clipboard via win32yank ---
if executable('win32yank.exe')

  " Push text to the Windows clipboard, with one retry and a visible warning.
  function! s:ClipCopy(text) abort
    call system('win32yank.exe -i --crlf', a:text)
    if v:shell_error
      call system('win32yank.exe -i --crlf', a:text)
      if v:shell_error
        echohl WarningMsg | echomsg 'win32yank copy failed (clipboard locked) - retry with :ClipSync' | echohl None
      endif
    endif
  endfunction

  " Copy: push every unnamed yank, delete and change to the Windows clipboard.
  " Linewise registers get their trailing newline back so paste stays linewise.
  augroup Win32YankCopy
    autocmd!
    autocmd TextYankPost *
          \ if index(['y', 'd', 'c'], v:event.operator) >= 0 && v:event.regname ==# '' |
          \   call s:ClipCopy(join(v:event.regcontents, "\n") . (v:event.regtype ==# 'V' ? "\n" : '')) |
          \ endif
  augroup END

  " Re-send the unnamed register to Windows (use after a 'clipboard locked' warning).
  command! ClipSync call s:ClipCopy(getreg('"') . (getregtype('"') ==# 'V' ? "\n" : ''))

  " Paste: pull the live Windows clipboard into the unnamed register, then paste.
  " Trailing newline -> linewise paste, so a copied whole line lands on its own line.
  function! WinClipPaste(after) abort
    let l:txt = system('win32yank.exe -o --lf')
    if l:txt =~# '\n$'
      call setreg('"', substitute(l:txt, '\n$', '', ''), 'l')
    else
      call setreg('"', l:txt, 'c')
    endif
    if a:after
      normal! ""p
    else
      normal! ""P
    endif
  endfunction
  nnoremap <silent> p :call WinClipPaste(1)<CR>
  nnoremap <silent> P :call WinClipPaste(0)<CR>
endif

" --- Start in the home directory ---
autocmd VimEnter * if argc() == 0 | cd ~ | endif

set number
