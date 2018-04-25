set viminfo+=n$XDG_CACHE_HOME/vim/viminfo
set runtimepath=$XDG_CONFIG_HOME/vim,$XDG_CONFIG_HOME/vim/after,$VIM,$VIMRUNTIME
set rtp+=/usr/share/vim/vimfiles
set rtp+=/usr/local/opt/fzf

execute pathogen#infect()

set showcmd
set listchars=tab:»⋅,trail:⁖
set list
set expandtab

map <silent> <Leader>t :Buffers<CR>
map <silent> <Leader>f :GFiles<CR>

let g:ale_linters = {'haskell': ['stack-build', 'hlint'],}
let g:ale_sign_column_always = 1

