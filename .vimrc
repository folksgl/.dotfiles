set number
set tabstop=2
set shiftwidth=4
set expandtab
set autoindent
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/
set term=screen-256color
colorscheme ron 


" Vim-Plug 
call plug#begin('~/.vim/plugged')

Plug 'scrooloose/syntastic'

call plug#end()
