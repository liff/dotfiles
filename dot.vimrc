set nocompatible  " be iMproved, required
filetype off      " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Load plugins
Plugin 'tpope/vim-fugitive'
Plugin 'derekwyatt/vim-scala'
Plugin 'wincent/command-t'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

" Put your non-Plugin stuff after this line
syntax on
set smartcase
set incsearch
set showmatch
