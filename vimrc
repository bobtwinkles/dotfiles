"
" Neobundle config
"

if has('vim_starting')
  set nocompatible

  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'

call neobundle#end()

NeoBundle 'airblade/vim-gitgutter.git'
NeoBundle 'Rip-Rip/clang_complete.git'
NeoBundle 'flazz/vim-colorschemes.git'
NeoBundle 'Raimondi/delimitMate.git'
NeoBundle 'scrooloose/syntastic.git'
NeoBundle 'dart-lang/dart-vim-plugin.git'
NeoBundle 'derekwyatt/vim-scala.git'
NeoBundleCheck

"GitGutter - show diff status when writing
let g:gitgutter_sign_column_always = 1

"clang_complete - C/C++ completiong using clang
let g:clang_make_default_keymappings = 0

"
"setup status line
"
set statusline=%t
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
set statusline+=%{&ff}] "file format
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag
set statusline+=%y      "filetype
set statusline+=%=      "left/right separator
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file"]
"Add syntastic status to the statusline
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

"
" custom tabline functions
"
function! MyTabLine()
    let s = '  |'
    for i in range(tabpagenr('$'))
        " Select highighting.
        if i + 1 == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif

        " Set the tab page number.
        let s .= '%' . (i + 1) . 'T'

        " The label is made by MyTabLabel()
        let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
        let s .= '%#TabLineFill#|'
    endfor

    let s .= '%#TabLineFill#%T'

    return s
endfunction

function! MyTabLabel(n)
    let buflist = tabpagebuflist(a:n)
    let winnr = tabpagewinnr(a:n)
    let file = bufname(buflist[winnr - 1])
    let numBuffers = len(buflist)
    "find any modified buffers
    let mod = 0 "false
    for buf in buflist
        if getbufvar(buf, "&mod")
            let mod = 1 "true
        endif
    endfor
    let mod = getbufvar(buflist[winnr - 1], "&mod")
    "build the tab string.
    let s = '['
    let s .= a:n
    let s .= '] '
    let s .= ((mod)?'*':'') . file
    let s .= ' (' . numBuffers . ')'
    return s
endfunction

set tabline=%!MyTabLine()
set showtabline=2
set laststatus=2

syntax on

" colors bubblegum
" colors rdark-terminal
" colors distinguished
" colors solarized
colors gruvbox
set background=dark

set fillchars+=vert:\ 
"set encoding
set encoding=utf-8

"
" misc. setup
"
" tab stuff
set tabstop=2
set shiftwidth=2
set expandtab
" current line number and jump numbers
set number
set relativenumber
" highlight background of current line
set cursorline
" BEEEP BEEEP BOOOOOOOP -> *blinky*
set visualbell
" highlight all search matches
set hlsearch
" display what will be tabbed through
set wildmenu

" Help the filetype system out a bit
au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl set syntax=glsl 
au BufNewFile,BufRead *.bcs set syntax=bc
filetype plugin indent on
"set smartindent
set nospell
set nowrap
"Turn off highlighting
nnoremap  <F3>     :noh<CR>
"Make latex-suite use latex highlighting
let g:tex_flavor='latex'

"
" custom command to set up an IDE-Like environment for c++
"
function! CPPNew(fname)
  let s:fname = join(split(a:fname, '\.')[:-2], '.')
  let s:cname = s:fname . '.cpp'
  let s:hname = s:fname . '.hpp'
  echom s:cname
  exe "tabnew " . fnameescape(s:cname)
  copen 3
  exe "vs " . fnameescape(s:hname)
endfunction
command! -nargs=1 -complete=file CPPOpen call CPPNew("<args>")

"
" some filetypes need extra configuration done once plugins have all loaded
"
function! FileTypeSpecialEnables()
  if &ft == 'c' || &ft == 'cpp'
    "  Disable preview buffer, we copen'd already
    set completeopt-=preview
    "  enable completion automatically
    let g:clang_complete_auto = 1

    "delimitMate - expand {<CR> to {<CR>}<ESC>O
    let g:delimitMate_expand_cr=1

    " Use the same config file for syntastic and clang_complete
    let g:syntastic_cpp_config_file='.clang_complete'
    "We want to fold things syntax style for c files
    set foldmethod=syntax
  elseif &ft == 'tex'
    "Do special things for tex files
    set wrap
    set spell
    call matchdelete(g:cc_match_group)
  elseif &ft == 'dart'
    " Disable syntastic autochecking for dart files because dartanalyzer is
    " incredibly slow
    let g:syntastic_mode_map = { "mode" : "passive" }
  elseif &ft == 'scala'
    " Disable syntastic autochecking for scala files because scala is
    " incredibly slow
    let g:syntastic_mode_map = { "mode" : "passive" }
  endif
endfunction

"We don't want things to be autofolded
set foldlevelstart=99
" "We also want to save folds when files close
" autocmd BufWinLeave *.* mkview
" autocmd BufWinEnter *.* silent loadview
"Show when a column slops over
let g:cc_match_group = matchadd('ColorColumn', '\%121v', 100)
"Show trailing spaces
set list
exec "set listchars=tab:\\|\\ ,trail:\uF8"

autocmd BufNewFile,BufRead * call FileTypeSpecialEnables()

" disable dumb gentoo word width stuff
autocmd BufNewFile,BufRead * set textwidth=0

" neovim usability stuff
if has('nvim')
  " enable python support
  runtime! plugin/plugin_setup.vim
  set backspace=indent,eol,start
endif
