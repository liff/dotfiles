if has("autocmd")
  filetype plugin indent on
endif

set smartcase
set incsearch
set showmatch

map <F2> :NERDTreeToggle<CR>

syntax match Tab /\t/
hi Tab gui=underline guifg=blue ctermbg=blue

