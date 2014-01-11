function MyTabLine()
    let s = 'b(o.o)b|'
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

function MyTabLabel(n)
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
""Switch colorscheme based on which terminal is running.
"if $TERM == 'rxvt-unicode-256color'
"    colors solarized
"endif
"if $TERM == 'rxvt-unicode'
"   colors solarized
"endif 
set background=dark
colors distinguished
set fillchars+=vert:\ 
"set encoding
set encoding=utf-8

set tabstop=4
set shiftwidth=4
set expandtab
set number
set relativenumber
set cursorline
au BufNewFile,BufRead *.frag,*.vert,*.fp,*.vp,*.glsl set syntax=glsl 
filetype plugin indent on
"set smartindent
au BufNewFile,BufRead *.c,*.cpp,*.h,*.hpp let g:clang_close_preview=1
set nospell
set nowrap
"Turn off highlighting
nnoremap  <F3>     :noh<CR>
"Make latex-suite use latex highlighting
let g:tex_flavor='latex'

"YCM config
let g:ycm_extra_conf_globlist = ['~/Code/CnCPP/*', '~/Code/hydra/*']
"Disable annoying preview buffer
set completeopt-=preview

"We want to fold things syntax style for c files
au BufNewFile,BufRead *.c,*.h,*.cpp,*.hpp,*.cc set foldmethod=syntax
"We don't want things to be autofolded
set foldlevelstart=99
"We also want to save folds when files close
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent loadview
"Show when a column slops over
call matchadd('ColorColumn', '\%121v', 100)
"Show trailing spaces
set list
exec "set listchars=trail:\uF8"
