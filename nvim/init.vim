set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc

augroup mac_clipboard
  au!
  au TextYankPost * call system("it2copy", @")
augroup END
