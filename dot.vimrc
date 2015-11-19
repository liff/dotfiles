set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'derekwyatt/vim-scala'

call vundle#end()

filetype plugin indent on
syntax on

set smartcase
set incsearch
set showmatch

map <F2> :NERDTreeToggle<CR>

syntax match Tab /\t/
hi Tab gui=underline guifg=blue ctermbg=blue

