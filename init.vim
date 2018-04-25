call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'lambdalisue/suda.vim'
Plug 'tpope/vim-fugitive'
Plug 'itchyny/lightline.vim'
Plug 'airblade/vim-gitgutter'
Plug 'w0rp/ale'
Plug 'junegunn/fzf.vim'
Plug 'robbles/logstash.vim'
Plug 'derekwyatt/vim-scala'
Plug 'rust-lang/rust.vim'
Plug 'neovimhaskell/haskell-vim'
Plug 'alx741/vim-hindent'
Plug 'alx741/vim-stylishask'
Plug 'purescript-contrib/purescript-vim'
Plug 'FrigoEU/psc-ide-vim'
call plug#end()

"set viminfo+=n$XDG_CACHE_HOME/vim/viminfo
"set runtimepath=$XDG_CONFIG_HOME/vim,$XDG_CONFIG_HOME/vim/after,$VIM,$VIMRUNTIME
"set rtp+=/usr/local/opt/fzf

set showcmd
set listchars=tab:»⋅,trail:⁖
set list
set expandtab

map <silent> <Leader>t :Buffers<CR>
map <silent> <Leader>f :GFiles<CR>

let g:ale_linters = {'haskell': ['stack-build', 'hlint'],}
let g:ale_sign_column_always = 1

