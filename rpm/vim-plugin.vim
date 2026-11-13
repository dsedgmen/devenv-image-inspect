" Packpath/vimfiles loader for devenv-image-inspect-vim RPM.
" Does not replace ~/.vimrc.
if exists('g:loaded_devenv_image_inspect')
  finish
endif
let g:loaded_devenv_image_inspect = 1

let s:share = '/usr/share/devenv-image-inspect'
if isdirectory(s:share . '/autoload')
  execute 'set runtimepath^=' . fnameescape(s:share)
endif
if filereadable(s:share . '/plugin/image-inspect.vim')
  execute 'source' fnameescape(s:share . '/plugin/image-inspect.vim')
else
  echohl ErrorMsg
  echomsg 'devenv-image-inspect: missing ' . s:share . '/plugin/image-inspect.vim'
  echohl None
endif
