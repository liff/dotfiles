execute pathogen#infect()

set showcmd
set listchars=tab:»⋅,trail:⁖
set list
set rtp+=/usr/local/opt/fzf
set expandtab

map <silent> <Leader>t :Buffers<CR>

let g:ale_linters = {'haskell': ['stack-build', 'hlint'],}
let g:ale_sign_column_always = 1

